# Tworzenie danych - Jakub Fabia

## Narzędzia
- [Chat GPT](https://chatgpt.com/) - Nazwy oraz opisy produktów
- Python z wykorzystaniem bibliotek:
    - pyodbc ze sterownikiem ODBC Driver 18 for SQL Server - łączenie się z bazą danych
    - json - odczyt plików JSON z nazwami i opisami produktów
    - random - tworzenie losowych wartości, prawdopodobieństwa wystąpienia
    - Faker - tworzenie losowych imion, nazwisk, adresów, email oraz numerów telefonu
    - uuid - tworzenie losowych ciągów znaków do linków
    - datetime - tworzenie realistycznych dat (np. tylko piątki, soboty itp.)

## Pliki

Wszystkie pliki można znaleźć w folderze [**tworzenie-danych**](/tworzenie-danych)

## Procedury do generowania danych początkowych:

### zInitialCourseRelatedTables

```sql
CREATE PROCEDURE zInitialCourseRelatedTables
AS
BEGIN
    SET NOCOUNT ON;CREATE PROCEDURE AddStudent
    @userID INT,
    @countryID INT,
    @city VARCHAR(50),
    @zip VARCHAR(10),
    @street VARCHAR(30),
    @houseNumber VARCHAR(5),
    @apartmentNumber VARCHAR(7) = NULL
AS
BEGIN
    BEGIN TRY
        -- Sprawdzenie czy użytkownik istnieje
        IF NOT EXISTS (SELECT 1 FROM Users WHERE userID = @userID)
            THROW 60006, 'UserID does not exist.', 1;

        -- Sprawdzenie czy kraj istnieje
        IF NOT EXISTS (SELECT 1 FROM Countries WHERE countryID = @countryID)
            THROW 60007, 'CountryID does not exist.', 1;

        -- Wstawianie nowego studenta
        INSERT INTO Students (userID, countryID, city, zip, street, houseNumber, apartmentNumber)
        VALUES (@userID, @countryID, @city, @zip, @street, @houseNumber, @apartmentNumber);
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
go

    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE @studentCounter INT = 0;
        WHILE @studentCounter < @capacity
        BEGIN
            SET @studentID = CAST((RAND() * (7091 - 4091) + 4091) AS INT);

            INSERT INTO Orders (studentID, paymentLink, createdAt)
            VALUES (@studentID, 'https://www.kaite.edu.pl/PaymentLink/' + CAST(@studentID AS VARCHAR), DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % DATEDIFF(DAY, '2020-01-01', GETDATE()), GETDATE()));

            DECLARE @orderID INT = SCOPE_IDENTITY();

            DECLARE @randomValue FLOAT = RAND();
            DECLARE @statusID INT =
                CASE
                    WHEN @randomValue <= 0.9 THEN 1
                    WHEN @randomValue <= 0.95 THEN 2
                    WHEN @randomValue <= 0.97 THEN 3
                    ELSE 4
                END;

            DECLARE @pricePaid MONEY;
            IF @statusID = 1 SET @pricePaid = (SELECT price FROM Products WHERE productID = @productID);
            ELSE IF @statusID = 2 SET @pricePaid = (SELECT price * 0.1 FROM Products WHERE productID = @productID);
            ELSE IF @statusID = 3 SET @pricePaid = 0;
            ELSE IF @statusID = 4 SET @pricePaid = (SELECT price * 0.05 FROM Products WHERE productID = @productID);

            INSERT INTO OrderDetails (orderID, productID, statusID, pricePaid)
            VALUES (@orderID, @productID, @statusID, @pricePaid);

            DECLARE meeting_cursor CURSOR FOR
            SELECT M.meetingID FROM Meetings M
            JOIN CourseModuleMeeting CMM ON M.meetingID = CMM.meetingID
            JOIN CourseModules CM ON CMM.moduleID = CM.moduleID
            JOIN Courses C ON CM.courseID = C.courseID
            WHERE C.courseID = @meetingID;

            OPEN meeting_cursor;

            DECLARE @attendedMeetings INT = 0;
            DECLARE @totalMeetings INT = 0;

            FETCH NEXT FROM meeting_cursor INTO @meetingID;

            WHILE @@FETCH_STATUS = 0
            BEGIN
                SET @totalMeetings = @totalMeetings + 1;
                DECLARE @present BIT = CASE WHEN RAND() > 0.2 THEN 1 ELSE 0 END;

                IF @present = 1
                    SET @attendedMeetings = @attendedMeetings + 1;

                INSERT INTO Attendence (meetingID, studentID, present, makeUp)
                VALUES (@meetingID, @studentID, @present, 0);

                FETCH NEXT FROM meeting_cursor INTO @meetingID;
            END

            CLOSE meeting_cursor;
            DEALLOCATE meeting_cursor;

            IF @totalMeetings > 0 AND (@attendedMeetings * 1.0 / @totalMeetings >= 0.8)
            BEGIN
                DECLARE @issuedAt DATETIME = GETDATE();
                INSERT INTO Certificates (studentID, productID, issuedAt)
                VALUES (@studentID, @productID, @issuedAt);
            END

            SET @studentCounter = @studentCounter + 1;
        END

        FETCH NEXT FROM course_cursor INTO @meetingID, @productID, @capacity;
    END
    
    CLOSE course_cursor;
    DEALLOCATE course_cursor;
END;
```

### zInitialCoursesWithModules

```sql
CREATE PROCEDURE zInitialCoursesWithModules
    @courseName VARCHAR(50),
    @courseDescription VARCHAR(200),
    @price MONEY,
    @capacity INT,
    @coordinatorID INT,
    @createdAt DATETIME,
    @module1name VARCHAR(50), @module1type VARCHAR(20), @module1datetime DATETIME,
    @module2name VARCHAR(50), @module2type VARCHAR(20), @module2datetime DATETIME,
    @module3name VARCHAR(50), @module3type VARCHAR(20), @module3datetime DATETIME,
    @module4name VARCHAR(50), @module4type VARCHAR(20), @module4datetime DATETIME
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @productID INT, @courseID INT, @moduleID INT, @meetingID INT

    INSERT INTO Products (price, name, description, createdAt)
    VALUES (@price, @courseName, @courseDescription,@createdAt);

    SET @productID = SCOPE_IDENTITY();

    IF @capacity = 0
    BEGIN
        INSERT INTO Courses (productID, coordinatorID)
        VALUES (@productID, @coordinatorID);
    END
    ELSE
    BEGIN 
        INSERT INTO Courses (productID, coordinatorID, capacity)
        VALUES (@productID, @coordinatorID, @capacity);
    end
    SET @courseID = SCOPE_IDENTITY();

    DECLARE @i INT = 1;
    WHILE @i <= 4
    BEGIN
        DECLARE @moduleName VARCHAR(50), @moduleType VARCHAR(20), @moduleDatetime DATETIME;

        IF @i = 1 BEGIN SET @moduleName = @module1name; SET @moduleType = @module1type; SET @moduleDatetime = @module1datetime; END
        IF @i = 2 BEGIN SET @moduleName = @module2name; SET @moduleType = @module2type; SET @moduleDatetime = @module2datetime; END
        IF @i = 3 BEGIN SET @moduleName = @module3name; SET @moduleType = @module3type; SET @moduleDatetime = @module3datetime; END
        IF @i = 4 BEGIN SET @moduleName = @module4name; SET @moduleType = @module4type; SET @moduleDatetime = @module4datetime; END

        INSERT INTO CourseModules (courseID, name)
        VALUES (@courseID, @moduleName);

        SET @moduleID = SCOPE_IDENTITY();

        INSERT INTO Meetings (teacherID)
        VALUES (CAST((RAND() * (301-42) + 42) AS INT));

        SET @meetingID = SCOPE_IDENTITY();

        INSERT INTO CourseModuleMeeting (meetingID, moduleID)
        VALUES (@meetingID, @moduleID);

        IF @moduleType = 'OnlineSync' BEGIN
            INSERT INTO OnlineSyncMeetings (meetingID, recordingLink, liveMeetingLink)
            VALUES (@meetingID, 'https://www.kaite.edu.pl/RecordingLink/' + CAST(@meetingID AS VARCHAR), 'https://www.kaite.edu.pl/MeetingLink/' + CAST(@meetingID AS VARCHAR));
        END
        ELSE IF @moduleType = 'OnlineAsync' BEGIN
            INSERT INTO OnlineAsyncMeetings (meetingID, recordingLink)
            VALUES (@meetingID, 'https://www.kaite.edu.pl/RecordingLink/' + CAST(@meetingID AS VARCHAR));
        END
        ELSE IF @moduleType = 'Stationary' BEGIN
            INSERT INTO StationaryMeetings (meetingID, locationID, capacity)
            VALUES (@meetingID, CAST(RAND() * 10 + 1 AS INT), @capacity);
        END

        INSERT INTO TimeSchedule (meetingID, startTime, duration)
        VALUES (@meetingID, @moduleDatetime, '01:30:00');

        SET @i = @i + 1;
    END
END;
```

### zInitialDropoutStudent

```sql
CREATE PROCEDURE zInitialDropoutStudent
    @studyID INT,
    @studentID INT,
    @semester INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @paymentLink VARCHAR(400);
    DECLARE @createdAt DATETIME;
    DECLARE @status INT;
    DECLARE @pricePaid DECIMAL(10,2);
    DECLARE @productPrice DECIMAL(10,2);
    DECLARE @productCreatedAt DATETIME;
    DECLARE @minStartTime DATETIME;
    DECLARE @OrderID INT;
    
    SET @paymentLink = 'https://www.kaite.edu.pl/paymentLink/' + CAST(NEWID() AS VARCHAR(36));

    SELECT @productCreatedAt = createdAt, @productPrice = price
    FROM Products
    WHERE productID = @studyID;

    SELECT @minStartTime = minstartTime
    FROM ProductBeginningDate
    WHERE productID = @studyID;

    SET @createdAt = DATEADD(DAY, ABS(CHECKSUM(NEWID())) % DATEDIFF(DAY, @productCreatedAt, DATEADD(DAY, -3, @minStartTime)), @productCreatedAt);

    INSERT INTO Orders (studentID, paymentLink, createdAt)
    VALUES (@studentID, @paymentLink, @createdAt);

    SET @OrderID = SCOPE_IDENTITY();

    DECLARE @RandomValue FLOAT = RAND();
    IF @RandomValue <= 0.9
    BEGIN
        SET @status = 1;
        SET @pricePaid = @productPrice;
    END
    ELSE IF @RandomValue <= 0.96
    BEGIN
        SET @status = 2;
        SET @pricePaid = @productPrice * 0.10;
    END
    ELSE IF @RandomValue <= 0.98
    BEGIN
        SET @status = 3;
        SET @pricePaid = 0;
    END
    ELSE
    BEGIN
        SET @status = 4;
        SET @pricePaid = @productPrice * 0.05;
    END

    INSERT INTO OrderDetails (orderID, productID, statusID, pricePaid)
    VALUES (@OrderID, @studyID, @status, @pricePaid);

    IF @semester >= 5
    BEGIN
        EXEC zInitialInternships @studyID, @studentID, @semester;
    END

    DECLARE @Counter INT = 1;
    WHILE @Counter < @semester
    BEGIN
        EXEC zInitialPassingAttendanceInSemester @studyID, @studentID, @Counter;
        SET @Counter = @Counter + 1;
    END
    EXEC zInitialNotPassingAttendanceInSemester @studyID, @studentID, @semester;
END;
```

### zInitialFutureStudent

```sql
CREATE PROCEDURE zInitialFutureStudent
    @studyID INT,
    @studentID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @paymentLink VARCHAR(400);
    DECLARE @createdAt DATETIME;
    DECLARE @status INT;
    DECLARE @pricePaid DECIMAL(10,2);
    DECLARE @productPrice DECIMAL(10,2);
    DECLARE @productCreatedAt DATETIME;
    DECLARE @OrderID INT;

    SET @paymentLink = 'https://www.kaite.edu.pl/paymentLink/' + CAST(NEWID() AS VARCHAR(36));

    SELECT @productCreatedAt = createdAt, @productPrice = price
    FROM Products
    WHERE productID = @studyID;

    SET @createdAt = DATEADD(DAY, ABS(CHECKSUM(NEWID())) % DATEDIFF(DAY, @productCreatedAt, DATEADD(DAY, -3, GETDATE())), @productCreatedAt);

    INSERT INTO Orders (studentID, paymentLink, createdAt)
    VALUES (@studentID, @paymentLink, @createdAt);
    SET @OrderID = SCOPE_IDENTITY()

    DECLARE @RandomValue FLOAT = RAND();
    IF @RandomValue <= 0.9
    BEGIN
        SET @status = 1;
        SET @pricePaid = @productPrice;
    END
    ELSE IF @RandomValue <= 0.96
    BEGIN
        SET @status = 2;
        SET @pricePaid = @productPrice * 0.10;
    END
    ELSE IF @RandomValue <= 0.98
    BEGIN
        SET @status = 3;
        SET @pricePaid = 0;
    END
    ELSE
    BEGIN
        SET @status = 4;
        SET @pricePaid = @productPrice * 0.05;
    END

    INSERT INTO OrderDetails (orderID, productID, statusID, pricePaid)
    VALUES (@OrderID, @studyID, @status, @pricePaid);

    DECLARE @Counter INT = 1;
    WHILE @Counter <= 7
    BEGIN
        EXEC zInitialNoAttendanceInSemester @studyID, @studentID, @Counter;
        SET @Counter = @Counter + 1;
    END
END;
```

### zInitialInternships

```sql
CREATE PROCEDURE zInitialInternships
    @studyID INT,
    @studentID INT,
    @semester INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @GeneratedMeetingID INT;
    DECLARE @startDate DATETIME;
    DECLARE @teacherID INT;

    SET @teacherID = (ABS(CHECKSUM(NEWID())) % (12 - 9 + 1)) + 9;

    SELECT @startDate = DATEADD(YEAR, 2, MIN(minStartTime))
    FROM ProductBeginningDate
    WHERE productID = @studyID;

    SET @startDate = DATEFROMPARTS(YEAR(@startDate), 8, 1);
    IF @startDate > GETDATE()
    BEGIN
        PRINT 'Start date is in the future. Procedure terminated.';
        RETURN;
    END

    INSERT INTO Meetings (teacherID)
    VALUES (@teacherID);

    SET @GeneratedMeetingID = SCOPE_IDENTITY();

    INSERT INTO Internships (studyID, meetingID)
    VALUES (@studyID, @GeneratedMeetingID)

    INSERT INTO InternshipMeetings (meetingID, startDate)
    VALUES (@GeneratedMeetingID, @startDate);

    INSERT INTO Attendence (meetingID, studentID, present)
    VALUES (@GeneratedMeetingID, @studentID, 1);

    IF @semester > 6
    BEGIN
        SELECT @startDate = DATEADD(YEAR, 3, MIN(minStartTime))
        FROM ProductBeginningDate
        WHERE productID = @studyID;

        SET @startDate = DATEFROMPARTS(YEAR(@startDate), 8, 1);

        IF @startDate > GETDATE()
        BEGIN
            PRINT 'Start date is in the future. Procedure terminated.';
            RETURN;
        END
        
        INSERT INTO Meetings (teacherID)
        VALUES (@teacherID);

        SET @GeneratedMeetingID = SCOPE_IDENTITY();

        INSERT INTO InternshipMeetings (meetingID, startDate)
        VALUES (@GeneratedMeetingID, @startDate);

        INSERT INTO Attendence (meetingID, studentID, present)
        VALUES (@GeneratedMeetingID, @studentID, 1);
    END
END;
```

### zInitialNoAttendanceInSemester

```sql
CREATE PROCEDURE zInitialNoAttendanceInSemester
    @studyID INT,
    @studentID INT,
    @semester INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @meetingID INT;
    DECLARE @present BIT;

    DECLARE meetingCursor CURSOR FOR
    SELECT SM.meetingID
    FROM SubjectMeeting SM
    JOIN Subjects S ON SM.subjectID = S.subjectID
    JOIN Meetings M ON SM.meetingID = M.meetingID
    JOIN TimeSchedule TS ON M.meetingID = TS.meetingID
    WHERE S.studyID = @studyID AND S.semester = @semester;

    OPEN meetingCursor;
    FETCH NEXT FROM meetingCursor INTO @meetingID;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @present = 0;
        INSERT INTO Attendence (meetingID, studentID, present)
        VALUES (@meetingID, @studentID, @present);

        FETCH NEXT FROM meetingCursor INTO @meetingID;
    END;

    CLOSE meetingCursor;
    DEALLOCATE meetingCursor;
END;
```

### zInitialNotPassingAttendanceInSemester

```sql
CREATE PROCEDURE zInitialNotPassingAttendanceInSemester
@studyID INT,
@studentID INT,
@semester INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @meetingID INT;
    DECLARE @present BIT;
    DECLARE @startTime DATETIME;

    DECLARE meetingCursor CURSOR FOR
    SELECT SM.meetingID, T.startTime
    FROM SubjectMeeting SM
    JOIN Subjects S ON SM.subjectID = S.subjectID
    JOIN TimeSchedule T ON SM.meetingID = T.meetingID
    WHERE S.studyID = @studyID AND S.semester = @semester;

    OPEN meetingCursor;
    FETCH NEXT FROM meetingCursor INTO @meetingID, @startTime;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF (RAND() <= 0.4)
            SET @present = 1;
        ELSE
            SET @present = 0;

        IF @present = 0 AND (RAND() <= 0.05)
            INSERT INTO Attendence (meetingID, studentID, present, makeUp)
            VALUES (@meetingID, @studentID, @present, 1);
        ELSE
            INSERT INTO Attendence (meetingID, studentID, present)
            VALUES (@meetingID, @studentID, @present);

        FETCH NEXT FROM meetingCursor INTO @meetingID, @startTime;
    END;

    CLOSE meetingCursor;
    DEALLOCATE meetingCursor;
END;
```

### zInitialNotPassingStudent

```sql
CREATE PROCEDURE zInitialNotPassingStudent
    @studyID INT,
    @studentID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @paymentLink VARCHAR(400);
    DECLARE @createdAt DATETIME;
    DECLARE @status INT;
    DECLARE @pricePaid DECIMAL(10,2);
    DECLARE @productPrice DECIMAL(10,2);
    DECLARE @productCreatedAt DATETIME;
    DECLARE @minStartTime DATETIME;
    DECLARE @semester INT;
    DECLARE @OrderID INT;

    SET @paymentLink = 'https://www.kaite.edu.pl/paymentLink/' + CAST(NEWID() AS VARCHAR(36));

    SELECT @productCreatedAt = createdAt, @productPrice = price
    FROM Products
    WHERE productID = @studyID;

    SELECT @minStartTime = minstartTime
    FROM ProductBeginningDate
    WHERE productID = @studyID;

    SET @semester = DATEDIFF(MONTH, @minStartTime, GETDATE()) / 5 + 1;

    SET @createdAt = DATEADD(DAY, ABS(CHECKSUM(NEWID())) % DATEDIFF(DAY, @productCreatedAt, DATEADD(DAY, -3, @minStartTime)), @productCreatedAt);

    INSERT INTO Orders (studentID, paymentLink, createdAt)
    VALUES (@studentID, @paymentLink, @createdAt);
    SET @OrderID = SCOPE_IDENTITY()
    
    DECLARE @RandomValue FLOAT = RAND();
    IF @RandomValue <= 0.9
    BEGIN
        SET @status = 1;
        SET @pricePaid = @productPrice;
    END
    ELSE IF @RandomValue <= 0.96
    BEGIN
        SET @status = 2;
        SET @pricePaid = @productPrice * 0.10;
    END
    ELSE IF @RandomValue <= 0.98
    BEGIN
        SET @status = 3;
        SET @pricePaid = 0;
    END
    ELSE
    BEGIN
        SET @status = 4;
        SET @pricePaid = @productPrice * 0.05;
    END

    INSERT INTO OrderDetails (orderID, productID, statusID, pricePaid)
    VALUES (@OrderID, @studyID, @status, @pricePaid);

    IF @semester >= 5
    BEGIN
        EXEC zInitialInternships @studyID, @studentID, @semester;
    END

    DECLARE @Counter INT = 1;
    WHILE @Counter < @semester
    BEGIN
        EXEC zInitialPassingAttendanceInSemester @studyID, @studentID, @Counter;
        SET @Counter = @Counter + 1;
    END
    EXEC zInitialNotPassingAttendanceInSemester @studyID, @studentID, @semester;
END;
```

### zInitialPassedStudent

```sql
CREATE PROCEDURE zInitialPassedStudent
    @studyID INT,
    @studentID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @paymentLink VARCHAR(400);
    DECLARE @createdAt DATETIME;
    DECLARE @status INT;
    DECLARE @pricePaid DECIMAL(10,2);
    DECLARE @productPrice DECIMAL(10,2);
    DECLARE @productCreatedAt DATETIME;
    DECLARE @minStartTime DATETIME;
    DECLARE @OrderID INT;

    SET @paymentLink = 'https://www.kaite.edu.pl/paymentLink/' + CAST(NEWID() AS VARCHAR(36));

    SELECT @productCreatedAt = createdAt, @productPrice = price
    FROM Products
    WHERE productID = @studyID;

    SELECT @minStartTime = minstartTime
    FROM ProductBeginningDate
    WHERE productID = @studyID;

    SET @createdAt = DATEADD(DAY, ABS(CHECKSUM(NEWID())) % DATEDIFF(DAY, @productCreatedAt, DATEADD(DAY, -3, @minStartTime)), @productCreatedAt);

    INSERT INTO Orders (studentID, paymentLink, createdAt)
    VALUES (@studentID, @paymentLink, @createdAt);

    SET @OrderID = SCOPE_IDENTITY();

    DECLARE @RandomValue FLOAT = RAND();
    IF @RandomValue <= 0.9
    BEGIN
        SET @status = 1;
        SET @pricePaid = @productPrice;
    END
    ELSE IF @RandomValue <= 0.96
    BEGIN
        SET @status = 2;
        SET @pricePaid = @productPrice * 0.10;
    END
    ELSE IF @RandomValue <= 0.98
    BEGIN
        SET @status = 3;
        SET @pricePaid = 0;
    END
    ELSE
    BEGIN
        SET @status = 4;
        SET @pricePaid = @productPrice * 0.05;
    END

    INSERT INTO OrderDetails (orderID, productID, statusID, pricePaid)
    VALUES (@orderID, @studyID, @status, @pricePaid);

    EXEC zInitialInternships @studyID, @studentID, 7;

    DECLARE @Counter INT = 1;
    WHILE @Counter <= 7
    BEGIN
        EXEC zInitialPassingAttendanceInSemester @studyID, @studentID, @Counter;
        SET @Counter = @Counter + 1;
    END
    
    INSERT INTO Certificates (studentID, productID, issuedAt)
    VALUES (@studentID, @studyID, DATEADD(YEAR, 4, @minStartTime));
END;
```

### zInitialPassingAttendanceInSemester

```sql
CREATE PROCEDURE zInitialPassingAttendanceInSemester
    @studyID INT,
    @studentID INT,
    @semester INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @meetingID INT;
    DECLARE @present BIT;

    DECLARE meetingCursor CURSOR FOR
    SELECT SM.meetingID
    FROM SubjectMeeting SM
    JOIN Subjects S ON SM.subjectID = S.subjectID
    JOIN Meetings M ON SM.meetingID = M.meetingID
    JOIN TimeSchedule TS ON M.meetingID = TS.meetingID
    WHERE S.studyID = @studyID AND S.semester = @semester AND startTime < GETDATE();

    OPEN meetingCursor;
    FETCH NEXT FROM meetingCursor INTO @meetingID;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF (RAND() <= 0.8)
            SET @present = 1;
        ELSE
            SET @present = 0;

        IF @present = 0 AND (RAND() <= 0.05)
            INSERT INTO Attendence (meetingID, studentID, present, makeUp)
        VALUES (@meetingID, @studentID, @present, 1);
        ELSE
            INSERT INTO Attendence (meetingID, studentID, present)
        VALUES (@meetingID, @studentID, @present);

        FETCH NEXT FROM meetingCursor INTO @meetingID;
    END;

    CLOSE meetingCursor;
    DEALLOCATE meetingCursor;
END;
```

### zInitialPassingStudent

```sql
CREATE PROCEDURE zInitialPassingStudent
    @studyID INT,
    @studentID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @paymentLink VARCHAR(400);
    DECLARE @createdAt DATETIME;
    DECLARE @status INT;
    DECLARE @pricePaid DECIMAL(10,2);
    DECLARE @productPrice DECIMAL(10,2);
    DECLARE @productCreatedAt DATETIME;
    DECLARE @minStartTime DATETIME;
    DECLARE @semester INT;
    DECLARE @OrderID INT;

    SET @paymentLink = 'https://www.kaite.edu.pl/paymentLink/' + CAST(NEWID() AS VARCHAR(36));

    SELECT @productCreatedAt = createdAt, @productPrice = price
    FROM Products
    WHERE productID = @studyID;

    SELECT @minStartTime = minstartTime
    FROM ProductBeginningDate
    WHERE productID = @studyID;

    SET @semester = DATEDIFF(MONTH, @minStartTime, GETDATE()) / 5 + 1;

    SET @createdAt = DATEADD(DAY, ABS(CHECKSUM(NEWID())) % DATEDIFF(DAY, @productCreatedAt, DATEADD(DAY, -3, @minStartTime)), @productCreatedAt);

    INSERT INTO Orders (studentID, paymentLink, createdAt)
    VALUES (@studentID, @paymentLink, @createdAt);
    SET @OrderID = SCOPE_IDENTITY()
    
    DECLARE @RandomValue FLOAT = RAND();
    IF @RandomValue <= 0.9
    BEGIN
        SET @status = 1;
        SET @pricePaid = @productPrice;
    END
    ELSE IF @RandomValue <= 0.96
    BEGIN
        SET @status = 2;
        SET @pricePaid = @productPrice * 0.10;
    END
    ELSE IF @RandomValue <= 0.98
    BEGIN
        SET @status = 3;
        SET @pricePaid = 0;
    END
    ELSE
    BEGIN
        SET @status = 4;
        SET @pricePaid = @productPrice * 0.05;
    END

    INSERT INTO OrderDetails (orderID, productID, statusID, pricePaid)
    VALUES (@OrderID, @studyID, @status, @pricePaid);

    IF @semester >= 5
    BEGIN
        EXEC zInitialInternships @studyID, @studentID, @semester;
    END

    DECLARE @Counter INT = 1;
    WHILE @Counter <= @semester
    BEGIN
        EXEC zInitialPassingAttendanceInSemester @studyID, @studentID, @Counter;
        SET @Counter = @Counter + 1;
    END
END;
```

### zInitialStudents

```sql
CREATE PROCEDURE zInitialStudents
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @Email NVARCHAR(100),
    @CountryID INT,
    @City NVARCHAR(50),
    @Zip NVARCHAR(20),
    @Street NVARCHAR(20),
    @HouseNumber NVARCHAR(10),
    @ApartmentNumber NVARCHAR(10) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @GeneratedUserID INT;

    INSERT INTO Users (firstName, lastName, email)
    VALUES (@FirstName, @LastName, @Email);

    SET @GeneratedUserID = SCOPE_IDENTITY();

    INSERT INTO Students (userID, countryID, city, zip, street, houseNumber, apartmentNumber)
    VALUES (@GeneratedUserID, @CountryID, @City, @Zip, @Street, @HouseNumber, @ApartmentNumber);
END;
```

### zInitialStudies

```sql
CREATE PROCEDURE zInitialStudies
    @studiesName VARCHAR(20),
    @description VARCHAR(200),
    @price MONEY,
    @capacity INT,
    @isAvailable BIT,
    @created DATETIME
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @GeneratedProductID INT;

    INSERT INTO Products (price, name, description, isAvailable, createdAt)
    VALUES (@price, @studiesName, @description, @isAvailable, @created);

    SET @GeneratedProductID = SCOPE_IDENTITY();

    INSERT INTO Studies (productID, capacity)
    VALUES (@GeneratedProductID, @capacity);
END;
```

### zInitialStudyCoordinators

```sql
CREATE PROCEDURE zInitialStudyCoordinators
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @Email NVARCHAR(100),
    @Phone NVARCHAR(20),
    @HireDate DATE,
    @RoleID1 INT,
    @RoleID2 INT,
    @RoleID3 INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @GeneratedUserID INT;
    DECLARE @GeneratedEmployeeID INT;
    
    INSERT INTO Users (firstName, lastName, email)
    VALUES (@FirstName, @LastName, @Email);

    SET @GeneratedUserID = SCOPE_IDENTITY();

    INSERT INTO Employees (userID, phone, hireDate)
    VALUES (@GeneratedUserID, @Phone, @HireDate);

    SET @GeneratedEmployeeID = SCOPE_IDENTITY(); 

    INSERT INTO EmployeeRole (employeeID, roleID)
    VALUES (@GeneratedEmployeeID, @RoleID1);

    INSERT INTO EmployeeRole (employeeID, roleID)
    VALUES (@GeneratedEmployeeID, @RoleID2);

    INSERT INTO EmployeeRole (employeeID, roleID)
    VALUES (@GeneratedEmployeeID, @RoleID3);
END;
```

### zInitialStudyMeetingOrders

```sql
CREATE PROCEDURE zInitialStudyMeetingOrders
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @productID INT, @studentID INT, @capacity INT, @filledCapacity INT, @orderDate DATETIME, @meetingID INT, @present BIT, @OrderID INT, @status INT, @price MONEY, @maximumDate DATETIME, @pricePaid MONEY, @randomDateTime DATETIME;

    DECLARE @i INT = 0;

    WHILE @i < 50
    BEGIN
        WAITFOR DELAY '00:00:00.1';
        SELECT @productID = CAST((RAND() * (6922 - 3494) + 3494) AS INT);

        SELECT @meetingID = meetingID, @price = price
        FROM Products
        JOIN SubjectMeeting ON Products.productID = SubjectMeeting.productID
        WHERE Products.productID = @productID

        SELECT @capacity = capacity
        FROM StationaryMeetings
        WHERE meetingID = @meetingID

        SELECT @filledCapacity = COUNT(*)
        FROM Attendence A
        WHERE meetingID = @meetingID

        IF @filledCapacity >= @capacity
            CONTINUE;

        SET @studentID = CAST((RAND() * (7091 - 4091) + 4091) AS INT);

        SELECT @maximumDate = DATEADD(DAY, -3, T.startTime)
        FROM TimeSchedule T
        WHERE meetingID = @meetingID
        IF @maximumDate > GETDATE()
        BEGIN
            EXEC zGenerateRandomDateTime '2020-01-01 15:00:00', '2024-12-31 15:00:00', @randomDateTime OUTPUT;
            SET @orderDate = @randomDateTime;
        END
        ELSE
        BEGIN
            EXEC zGenerateRandomDateTime '2020-01-01 15:00:00', @maximumDate, @randomDateTime OUTPUT;
            SET @orderDate = @randomDateTime;
        END

        PRINT 'Selected Meeting ID: ' + CAST(@meetingID AS VARCHAR);
        PRINT 'date: ' + CAST(@orderDate AS VARCHAR)

        INSERT INTO Orders (studentID, paymentLink, createdAt)
        VALUES (@studentID, 'https://www.kaite.edu.pl/PaymentLink/' + CAST(@studentID AS VARCHAR) + CAST(@meetingID AS VARCHAR), @orderDate);

        SET @OrderID = SCOPE_IDENTITY()

        DECLARE @RandomValue FLOAT = RAND();

        IF @RandomValue <= 0.9
        BEGIN
            SET @status = 1;
            SET @pricePaid = @price;
        END
        ELSE IF @RandomValue <= 0.96
        BEGIN
            SET @status = 2;
            SET @pricePaid = @price * 0.10;
        END
        ELSE IF @RandomValue <= 0.98
        BEGIN
            SET @status = 3;
            SET @pricePaid = 0;
        END
        ELSE
        BEGIN
            SET @status = 4;
            SET @pricePaid = @price * 0.05;
        END

        INSERT INTO OrderDetails (orderID, productID, statusID, pricePaid)
        VALUES (@OrderID, @productID, @status, @pricePaid)

        IF RAND() <= 0.9
        BEGIN
            SET @present = 1
        END
        ELSE
        BEGIN
            SET @present = 0
        end

        INSERT INTO Attendence (meetingID, studentID, present)
        VALUES (@meetingID, @studentID, @present)

        SET @i = @i + 1;
    END
END;
```

### zInitialSubjectCoordinators

```sql
CREATE PROCEDURE zInitialSubjectCoordinators
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @Email NVARCHAR(100),
    @Phone NVARCHAR(20),
    @HireDate DATE,
    @RoleID1 INT,
    @RoleID2 INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @GeneratedUserID INT;
    DECLARE @GeneratedEmployeeID INT;

    INSERT INTO Users (firstName, lastName, email)
    VALUES (@FirstName, @LastName, @Email);

    SET @GeneratedUserID = SCOPE_IDENTITY();

    INSERT INTO Employees (userID, phone, hireDate)
    VALUES (@GeneratedUserID, @Phone, @HireDate);

    SET @GeneratedEmployeeID = SCOPE_IDENTITY(); 

    INSERT INTO EmployeeRole (employeeID, roleID)
    VALUES (@GeneratedEmployeeID, @RoleID1);

    INSERT INTO EmployeeRole (employeeID, roleID)
    VALUES (@GeneratedEmployeeID, @RoleID2);
END;
```

### zInitialSubjects

```sql
CREATE PROCEDURE zInitialSubjects
    @studyId INT,
    @coordinator INT,
    @name VARCHAR(30),
    @sylLink VARCHAR(400),
    @semester INT,
    @startDate DATETIME,
    @description VARCHAR(150),
    @capacity INT,
    @isStationary INT,
    @liveMeetingLink VARCHAR(400) = NULL,
    @recordingLink VARCHAR(400) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @GeneratedSubjectID INT;
    DECLARE @GeneratedMeetingID INT;
    DECLARE @GeneratedProductID INT;
    DECLARE @createdAt DATETIME;
    DECLARE @price DECIMAL(10,2);
    DECLARE @isAvailable BIT;
    DECLARE @teacherID INT;
    DECLARE @Counter INT = 1;
    DECLARE @time DATETIME;
    DECLARE @roomNumber INT;

    INSERT INTO Subjects (studyID, subjectCoordinatorID, subjectName, syllabusLink, semester)
    VALUES (@studyId, @coordinator, @name, @sylLink, @semester);

    SET @GeneratedSubjectID = SCOPE_IDENTITY();

    SELECT @createdAt = createdAt
    FROM Products
    JOIN Studies ON Products.productID = Studies.productID
    WHERE studyID = @studyID;

    SET @teacherID = (ABS(CHECKSUM(NEWID())) % (301 - 42 + 1)) + 42;
    SET @time = @startDate;

    SET @price = (ABS(CHECKSUM(NEWID())) % (200 - 100 + 1)) + 100;

    WHILE @Counter <= 9
    BEGIN
        IF DATEDIFF(DAY, GETDATE(), @startDate) <= 3 OR @startDate < GETDATE()
            SET @isAvailable = 0;
        ELSE
            SET @isAvailable = 1;

        INSERT INTO Products (price, name, description, createdAt, isAvailable)
        VALUES (@price, @name, @description, @createdAt, @isAvailable);

        SET @GeneratedProductID = SCOPE_IDENTITY();

        INSERT INTO Meetings (teacherID)
        VALUES (@teacherID);

        SET @GeneratedMeetingID = SCOPE_IDENTITY();

        IF @isStationary = 1
        BEGIN
            SET @roomNumber = (ABS(CHECKSUM(NEWID())) % (156 - 1 + 1)) + 1;
            INSERT INTO StationaryMeetings (meetingID, locationID)
            VALUES (@GeneratedMeetingID, @roomNumber);
        END
        ELSE IF @isStationary = 0
        BEGIN
            INSERT INTO OnlineSyncMeetings (meetingID, liveMeetingLink, recordingLink)
            VALUES (@GeneratedMeetingID, @liveMeetingLink, @recordingLink);
        END
        ELSE IF @isStationary = -1
        BEGIN
            INSERT INTO OnlineAsyncMeetings (meetingID, recordingLink)
            VALUES (@GeneratedMeetingID, @recordingLink);
        END

        INSERT INTO SubjectMeeting (meetingID, subjectID, productID, capacity)
        VALUES (@GeneratedMeetingID, @GeneratedSubjectID, @GeneratedProductID, @capacity);

        INSERT INTO TimeSchedule (meetingID, startTime)
        VALUES (@GeneratedMeetingID, @time);

        SET @startDate = DATEADD(DAY, 14, @startDate);
        SET @time = @startDate;
        SET @Counter = @Counter + 1;
    END
END;
```

### zInitialTeachers

```sql
CREATE PROCEDURE zInitialTeachers
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @Email NVARCHAR(100),
    @Phone NVARCHAR(20),
    @HireDate DATE,
    @RoleID INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @GeneratedUserID INT;
    DECLARE @GeneratedEmployeeID INT;

    INSERT INTO Users (firstName, lastName, email)
    VALUES (@FirstName, @LastName, @Email);

    SET @GeneratedUserID = SCOPE_IDENTITY();

    INSERT INTO Employees (userID, phone, hireDate)
    VALUES (@GeneratedUserID, @Phone, @HireDate);

    SET @GeneratedEmployeeID = SCOPE_IDENTITY();

    INSERT INTO EmployeeRole (employeeID, roleID)
    VALUES (@GeneratedEmployeeID, @RoleID);
END;
```

### zInitialTranslators

```sql
CREATE PROCEDURE zInitialTranslators
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @meetingID INT,
            @employeeID INT,
            @languageID INT;
    DECLARE @i INT = 0;

    WHILE @i < 50
    BEGIN
        WAITFOR DELAY '00:00:00.01';
        SET @employeeID = CAST(RAND() * (41 - 31) + 31 AS INT);
        SET @meetingID = CAST(RAND() * (9697-3484) + 3484 AS INT);

        IF (SELECT teacherID FROM Meetings WHERE meetingID = @meetingID) IS NULL OR @employeeID = 37
        BEGIN
            CONTINUE;
        END

        SELECT @languageID = languageID
        FROM EmployeeLanguages
        WHERE languageID != 1 AND employeeID = @employeeID
        
        PRINT CAST(@languageID AS VARCHAR) + ' ' + CAST(@employeeID AS VARCHAR) + ' ' + CAST(@meetingID AS VARCHAR)
        
        INSERT INTO Translators (meetingID, translatorID, languageID)
        VALUES (@meetingID, @employeeID, @languageID);

        SET @i = @i + 1;
    END
END;
```

### zInitialWebinarWithOrders

```sql
CREATE PROCEDURE zInitialWebinarWithOrders
    @webinarName VARCHAR(50),
    @webinarDescription VARCHAR(200),
    @price MONEY,
    @meetingType VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @productID INT, @meetingID INT, @statusID INT, @pricePaid MONEY, @studentID INT, @orderID INT, @webinarID INT, @startTime DATETIME, @startHour INT;
    
    INSERT INTO Products (price, name, description, createdAt)
    VALUES (@price, @webinarName, @webinarDescription, GETDATE());

    SET @productID = SCOPE_IDENTITY();
    
    INSERT INTO Meetings (teacherID)
    VALUES (CAST((RAND() * (301-42) + 42) AS INT));

    SET @meetingID = SCOPE_IDENTITY();
    
    SET @startTime = DATEADD(DAY, ABS(CHECKSUM(NEWID())) % DATEDIFF(DAY, '2022-01-01', '2025-03-01'), '2022-01-01');
    SET @startHour = CAST(9 + (RAND() * 8) AS INT);
    SET @startTime = DATEADD(HOUR, @startHour, @startTime);

    INSERT INTO TimeSchedule (meetingID, startTime, duration)
    VALUES (@meetingID, @startTime, '01:30:00');

    INSERT INTO Webinars (productID, meetingID)
    VALUES (@productID, @meetingID);

    SET @webinarID = SCOPE_IDENTITY();

    IF @meetingType = 'OnlineSync'
    BEGIN
        INSERT INTO OnlineSyncMeetings (meetingID, recordingLink, liveMeetingLink)
        VALUES (@meetingID, 'https://www.kaite.edu.pl/RecordingLink/' + CAST(@meetingID AS VARCHAR), 'https://www.kaite.edu.pl/MeetingLink/' + CAST(@meetingID AS VARCHAR));
    END
    ELSE IF @meetingType = 'OnlineAsync'
    BEGIN
        INSERT INTO OnlineAsyncMeetings (meetingID, recordingLink)
        VALUES (@meetingID, 'https://www.kaite.edu.pl/RecordingLink/' + CAST(@meetingID AS VARCHAR));
    END

    DECLARE @i INT = 0;
    DECLARE @usedStudentIDs TABLE (studentID INT);
    WHILE @i < 10
    BEGIN
        WAITFOR DELAY '00:00:00.100';
        SET @studentID = CAST((RAND() * (7091 - 4091) + 4091) AS INT);
        WHILE EXISTS (SELECT 1 FROM @usedStudentIDs WHERE studentID = @studentID)
        BEGIN
            SET @studentID = CAST((RAND() * (7091 - 4091) + 4091) AS INT);
        END

        INSERT INTO @usedStudentIDs (studentID) VALUES (@studentID);

        INSERT INTO Orders (studentID, paymentLink, createdAt)
        VALUES (@studentID, 'https://www.kaite.edu.pl/PaymentLink/' + CAST(@studentID AS VARCHAR), GETDATE());

        SET @orderID = SCOPE_IDENTITY();

        DECLARE @randomValue FLOAT = RAND();
        SET @statusID = CASE
            WHEN @randomValue <= 0.9 THEN 1
            WHEN @randomValue <= 0.95 THEN 2
            WHEN @randomValue <= 0.97 THEN 3
            ELSE 4
        END;

        SET @pricePaid = 
            CASE @statusID 
                WHEN 1 THEN @price
                WHEN 2 THEN @price * 0.1
                WHEN 3 THEN 0
                WHEN 4 THEN @price * 0.05
            END;

        INSERT INTO OrderDetails (orderID, productID, statusID, pricePaid)
        VALUES (@orderID, @productID, @statusID, @pricePaid);
        DECLARE @present BIT;
        IF @startTime > GETDATE()
            SET @present = 0;
        ELSE
            SET @present = CASE WHEN RAND() <= 0.7 THEN 1 ELSE 0 END;

        INSERT INTO Attendence (meetingID, studentID, present, makeUp)
        VALUES (@meetingID, @studentID, @present, 0);

        SET @i = @i + 1;
    END
END;
```
