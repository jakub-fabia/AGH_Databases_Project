# Procedury

## Dodawanie kursu - Seweryn Tasior

```sql
CREATE PROCEDURE AddCourse
    @name VARCHAR(50),
    @description VARCHAR(200),
    @price MONEY,
    @coordinatorID INT,
    @capacity INT = NULL
AS
BEGIN
    DECLARE @ProductID INT;
    DECLARE @CourseID INT;

    IF (@price <= 0)
        BEGIN
            RAISERROR ('Cena kursu musi być większa niż 0.', 16, 1);
        END
    IF (@capacity <= 0)
        BEGIN
            RAISERROR ('Pojemność kursu musi być większa niż 0. (Jeśli jest konieczna)', 16, 1);
        END

    INSERT INTO Products (price, name, description) VALUES
    (@price, @name, @description);

    SET @ProductID = SCOPE_IDENTITY()

    -- Sprawdzenie czy koordynator istnieje w tabeli Employees
    IF NOT EXISTS
        (SELECT 1 FROM Employees WHERE employeeID = @coordinatorID)
        BEGIN
            RAISERROR ('Niepoprawne ID Pracownika.', 16, 1);
        END

    -- Sprawdzenie czy koordynator ma przypisaną rolę 'Koordynator Kursów'
    IF NOT EXISTS
        (SELECT 1
        FROM EmployeeRole ER
        INNER JOIN Roles R ON ER.roleID = R.roleID
        WHERE ER.employeeID = @coordinatorID AND R.roleName = 'Koordynator Kursów')
        BEGIN
            RAISERROR (N'Pracownik nie ma przypisanej roli Koordynator Kursów.', 16, 1);
        END

    -- Dodawanie nowego kursu z określoną pojemnością
    INSERT INTO Courses (productID, coordinatorID, capacity)
    VALUES (@productID, @coordinatorID, @capacity);

    SET @CourseID = SCOPE_IDENTITY()

    PRINT 'Kurs dodany pomyślnie!';
    PRINT 'Detale:';
    PRINT CONCAT('Numer produktu: ', @ProductID);
    PRINT CONCAT('Numer krusu: ', @CourseID);
END;
GO
```

## Dodawanie Modułu do Kursu - Seweryn Tasior

```sql
CREATE PROCEDURE AddCourseModule
    @courseID INT,
    @name VARCHAR(50)
AS
BEGIN
    DECLARE @ModuleID INT;
    -- Sprawdzenie czy kurs istnieje
    IF NOT EXISTS (SELECT 1 FROM Courses WHERE courseID = @courseID)
        BEGIN
            RAISERROR ('ID kursu nie istnieje.', 16, 1);
        END

    -- Dodawanie modułu do kursu
    INSERT INTO CourseModules (courseID, name)
    VALUES (@courseID, @name);
    SET @ModuleID = SCOPE_IDENTITY();

    PRINT 'Moduł pomyślnie dodany do kursu!';
    PRINT 'Detale:';
    PRINT CONCAT('Numer krusu: ', @CourseID);
    PRINT CONCAT('Numer modułu: ', @ModuleID);
END;
GO
```

## Dodawanie Spotkania do Modułu Kursu - Seweryn Tasior

```sql
CREATE PROCEDURE AddCourseModuleMeeting
    @ModuleID INT,
    @Type VARCHAR(15),
    @teacherID INT,
    @startDatetime DATETIME,
    @duration TIME,
    @TranslatorID INT = NULL,
    @languageID INT = NULL,
    @roomID INT = NULL
AS
BEGIN
    DECLARE @meetingID INT;
    DECLARE @capacity INT;

    SET @capacity = (SELECT capacity FROM Courses JOIN dbo.CourseModules CM on Courses.courseID = CM.courseID WHERE moduleID = @ModuleID);

    -- Sprawdzenie czy kurs istnieje
    IF NOT EXISTS (SELECT 1 FROM CourseModules WHERE moduleID = @ModuleID)
        BEGIN
            RAISERROR ('ID Modułu nie istnieje.', 16, 1);
        END

    EXEC @meetingID = AddMeetingWithDetails @teacherID, @startDatetime, @duration, @Type, @roomID, @capacity, NULL, NULL, @TranslatorID, @languageID

    INSERT INTO CourseModuleMeeting (meetingID, moduleID) VALUES (@meetingID, @moduleID)

    PRINT 'Spotkanie pomyślnie dodane do modułu!';
    PRINT 'Detale:';
    PRINT CONCAT('Numer modułu: ', @ModuleID);
    PRINT CONCAT('Numer spotkania: ', @meetingID);
END;
go
```

## Dodawanie Pracownika - Mariusz Krause

```sql
CREATE PROCEDURE AddEmployee
    @firstName VARCHAR(20),
    @lastName VARCHAR(20),
    @email VARCHAR(50),
    @phone VARCHAR(20)
AS
BEGIN
    BEGIN TRY
        DECLARE @userID INT;
        INSERT INTO Users (firstName, lastName, email) VALUES (@firstName, @lastName, @email)
        SET @userID = SCOPE_IDENTITY();
        INSERT INTO Employees (userID, phone) VALUES (@userID, @phone)
    END TRY
    BEGIN CATCH
        DELETE FROM Users WHERE userID = @userID
        RAISERROR ('Niepoprawne Dane!', 16, 1);
    end catch
END;
GO
```

## Dodawanie stażu - Jakub Fabia

```sql
CREATE PROCEDURE AddInternship
    @employeeID INT,
    @studentID INT,
    @studyID INT,
    @startDate DATE,
    @passed BIT
AS
BEGIN
    BEGIN TRY
        DECLARE @meetingID INT;
        IF NOT EXISTS (SELECT 1 FROM Studies WHERE studyID = @studyID)
            THROW 60004, 'StudyID does not exist.', 1;

        IF NOT EXISTS (SELECT 1 FROM EmployeeRole WHERE employeeID = @employeeID and roleID = 4)
            THROW 61001, 'Wrong EmployeeID or the employee is not an internship coordinator.', 1;

        IF NOT EXISTS (SELECT 1 FROM Orders LEFT OUTER JOIN dbo.OrderDetails OD on Orders.orderID = OD.orderID
                                        JOIN dbo.Products P on P.productID = OD.productID
                                        JOIN dbo.Studies S on P.productID = S.productID
                                        WHERE @studentID = studentID AND studyID = @studyID)
            THROW 61002, 'Student is not a part of the study.', 1;

        INSERT INTO Meetings (teacherID) VALUES (@employeeID)
        SET @meetingID = SCOPE_IDENTITY();

        INSERT INTO InternshipMeetings (meetingID, startDate) VALUES (@meetingID, @startDate)
        INSERT INTO Attendence (meetingID, studentID, present) VALUES (@meetingID, @studentID, @passed)
        INSERT INTO Internships (studyID, meetingID) VALUES (@studyID, @meetingID);
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
GO
```

## Dodawanie Spotkania (procedura wykorzystywana przez inne procedury) - Jakub Fabia

```sql
CREATE PROCEDURE AddMeetingWithDetails
    @teacherID INT,
    @startTime DATETIME,
    @duration TIME,
    @meetingType NVARCHAR(50),
    @locationID INT = NULL,
    @capacity INT = NULL,
    @recordingLink NVARCHAR(400) = NULL,
    @liveMeetingLink NVARCHAR(400) = NULL,
    @translatorID INT = NULL,
    @languageID INT = NULL
AS
BEGIN
    BEGIN TRY
        DECLARE @meetingID INT;
        -- Sprawdzenie poprawności startTime i duration
        IF @startTime < GETDATE()
            THROW 61002, 'StartTime must be after today.', 1;

        IF @duration < '00:15:00' OR @duration > '04:30:00'
            THROW 61003, 'Duration must be between 15 minutes and 4 hours 30 minutes.', 1;

        -- Sprawdzenie, czy teacherID istnieje
        IF NOT EXISTS (SELECT 1 FROM EmployeeRole WHERE employeeID = @teacherID and roleID = 6)
            THROW 61001, 'Wrong TeacherID of the employee is not a teacher.', 1;

        -- Wstawienie rekordu do tabeli Meetings
        INSERT INTO Meetings (teacherID)
        VALUES (@teacherID);

        -- Pobranie ID utworzonego meetingu
        SET @meetingID = SCOPE_IDENTITY();
        PRINT @meetingID

        -- Dodanie harmonogramu spotkania
        INSERT INTO TimeSchedule (meetingID, startTime, duration)
        VALUES (@meetingID, @startTime, @duration);

        -- Dodanie StationaryMeeting
        IF @meetingType = 'Stationary'
            BEGIN
                IF @locationID IS NULL
                    BEGIN
                        SET @locationID = (SELECT TOP 1 locationID
                                        FROM (SELECT locationID FROM Location
                                        EXCEPT
                                        SELECT locationID FROM RoomSchedule
                        WHERE startTime BETWEEN @startTime AND DATEADD(SECOND, DATEDIFF(SECOND, '00:00:00', @duration), @startTime) 
                        AND endTime BETWEEN @startTime AND DATEADD(SECOND, DATEDIFF(SECOND, '00:00:00', @duration), @startTime)) as LlIRSlI);
                    END 
                ELSE
                    BEGIN 
                        IF EXISTS (SELECT 1 FROM RoomSchedule WHERE startTime BETWEEN @startTime AND DATEADD(SECOND, DATEDIFF(SECOND, '00:00:00', @duration), @startTime) 
                                    AND endTime BETWEEN @startTime AND DATEADD(SECOND, DATEDIFF(SECOND, '00:00:00', @duration), @startTime) AND locationID = @locationID)    
                            THROW 61008, 'Room is not empty at that time.', 1;
                    end
                IF NOT EXISTS (SELECT 1 FROM Location WHERE locationID = @locationID)
                    THROW 61005, 'LocationID does not exist.', 1;

                IF @capacity IS NULL OR @capacity <= 0
                    THROW 61006, 'Capacity must be a positive integer for Stationary meetings.', 1;
                    
                INSERT INTO StationaryMeetings (meetingID, locationID, capacity)
                VALUES (@meetingID, @locationID, @capacity);
            END
            -- Dodanie OnlineSyncMeeting
        ELSE IF @meetingType = 'OnlineSync'
            BEGIN
                IF @recordingLink IS NULL
                    BEGIN
                        SET @recordingLink = CONCAT('https://www.kaite.edu.pl/RecordingLink/', @meetingID);
                    end
                IF @liveMeetingLink IS NULL
                    BEGIN
                        SET @liveMeetingLink = CONCAT('https://www.kaite.edu.pl/MeetingLink/', @meetingID);
                    end
                INSERT INTO OnlineSyncMeetings (meetingID, recordingLink, liveMeetingLink)
                VALUES (@meetingID, @recordingLink, @liveMeetingLink);
            END
            -- Dodanie OnlineAsyncMeeting
        ELSE IF @meetingType = 'OnlineAsync'
            BEGIN
                IF @recordingLink IS NULL
                    BEGIN
                        SET @recordingLink = CONCAT('https://www.kaite.edu.pl/RecordingLink/', @meetingID);
                    end
                INSERT INTO OnlineAsyncMeetings (meetingID, recordingLink)
                VALUES (@meetingID, @recordingLink);
            END
        ELSE
            THROW 61012, 'Invalid MeetingType. Valid values are: Stationary, OnlineSync, OnlineAsync.', 1;

        -- Opcjonalne dodanie tłumacza
        IF @translatorID IS NOT NULL 
            BEGIN
            IF dbo.IsTranslatorValid(@translatorID, @languageID) = 1
                BEGIN
                    INSERT INTO Translators (meetingID, translatorID, languageID)
                    VALUES (@meetingID, @translatorID, @languageID);
                END
            ELSE
                BEGIN
                    PRINT 'Translator is not valid!';
                end
            END
    END TRY
    BEGIN CATCH
        -- Obsługa błędów
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
    RETURN @meetingID
END;
go
```

## Dodawanie zamówienia (z jednym przedmiotem) - Mariusz Krause

```sql
CREATE PROCEDURE AddOrder
    @studentID INT,
    @paymentLink VARCHAR(400),
    @productID INT,
    @statusID INT,
    @pricePaid MONEY
AS
BEGIN
    DECLARE @OrderID INT;
    -- Sprawdzenie czy student istnieje
    IF NOT EXISTS (SELECT 1 FROM Students WHERE studentID = @studentID)
        BEGIN
            RAISERROR ('ID studenta nie istnieje.', 16, 1);
        END
    -- Sprawdzenie czy link do płatności jest poprawny
    IF @paymentLink NOT LIKE 'https://www.kaite.edu.pl/PaymentLink/%'
        BEGIN
            RAISERROR (N'Nieprawidłowy link do płatności.', 16, 1);
        END
    -- Dodawanie nowego zamówienia
    INSERT INTO Orders (studentID, paymentLink)
    VALUES (@studentID, @paymentLink);

    SET @OrderID = SCOPE_IDENTITY()
    -----------------------------------------
    -- Sprawdzenie czy produkt istnieje
    IF NOT EXISTS (SELECT 1 FROM Products WHERE productID = @productID)
        BEGIN
            RAISERROR ('ID produktu nie istnieje.', 16, 1);
        END

    -- Sprawdzenie czy status istnieje
    IF NOT EXISTS (SELECT 1 FROM OrderStatus WHERE statusID = @statusID)
        BEGIN
            RAISERROR ('ID statusu nie istnieje.', 16, 1);
        END

    -- Sprawdzenie czy student nie ma już tego produktu
    IF EXISTS (
        SELECT 1
        FROM OrderDetails OD
                 INNER JOIN Orders O ON OD.orderID = O.orderID
        WHERE O.studentID  IN  (SELECT studentID FROM Orders WHERE orderID = @orderID)
          AND OD.productID = @productID
    )
        BEGIN
            RAISERROR (N'Student ma już zamwówiony ten produkt.', 16, 1);
        END
    --- Sprawdzenie czy cena za produkt jest dodatnia
    IF (@pricePaid<= 0)
        BEGIN
            RAISERROR ('Cena za produkt jest nie wlasciwa', 16, 1);
        END
    -- Wstawianie szczegółów zamówienia
    INSERT INTO OrderDetails (orderID, productID, statusID, pricePaid)
    VALUES (@OrderID, @productID, @statusID, @pricePaid);


    PRINT 'Zamowienie dodany pomyślnie!';
    PRINT 'Detale:';
    PRINT CONCAT('Numer zamówienia: ', @OrderID);
END;
go
```

## Dodawanie Przedmiotów do już istniejącego zamówienia - Mariusz Krause

```sql
CREATE PROCEDURE AddOrderDetails
    @orderID INT,
    @productID INT,
    @statusID INT,
    @pricePaid MONEY
AS
BEGIN
    -- Sprawdzenie czy zamówienie istnieje
    IF NOT EXISTS (SELECT 1 FROM Orders WHERE orderID = @orderID)
        BEGIN
            RAISERROR ('ID zamówienia nie istnieje.', 16, 1);
            RETURN;
        END

    -- Sprawdzenie czy produkt istnieje
    IF NOT EXISTS (SELECT 1 FROM Products WHERE productID = @productID)
        BEGIN
            RAISERROR ('ID produktu nie istnieje.', 16, 1);
            RETURN;
        END

    -- Sprawdzenie czy status istnieje
    IF NOT EXISTS (SELECT 1 FROM OrderStatus WHERE statusID = @statusID)
        BEGIN
            RAISERROR ('ID statusu nie istnieje.', 16, 1);
            RETURN;
        END

    -- Sprawdzenie czy student nie ma już tego produktu
    IF EXISTS (
        SELECT 1
        FROM OrderDetails OD
                 INNER JOIN Orders O ON OD.orderID = O.orderID
        WHERE O.studentID  IN  (SELECT studentID FROM Orders WHERE orderID = @orderID)
          AND OD.productID = @productID
    )
        BEGIN
            RAISERROR (N'Student ma już zamwówiony ten produkt.', 16, 1);
            RETURN;
        END

    -- Wstawianie szczegółów zamówienia
    INSERT INTO OrderDetails (orderID, productID, statusID, pricePaid)
    VALUES (@orderID, @productID, @statusID, @pricePaid);
END;
GO
```

## Dodawnie Studenta - Seweryn Tasior

```sql
CREATE PROCEDURE AddStudent
    @firstName VARCHAR(20),
    @lastName VARCHAR(20),
    @email VARCHAR(50),
    @countryID INT,
    @city VARCHAR(50),
    @zip VARCHAR(10),
    @street VARCHAR(30),
    @houseNumber VARCHAR(5),
    @apartmentNumber VARCHAR(7) = NULL
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Countries WHERE countryID = @countryID)
        BEGIN
            RAISERROR ('Niepoprawny kraj!', 16, 1);
        END
    BEGIN TRY
        DECLARE @userID INT;
        DECLARE @studentID INT;
        INSERT INTO Users (firstName, lastName, email) VALUES (@firstName, @lastName, @email)
        SET @userID = SCOPE_IDENTITY();
        INSERT INTO Students (userID, countryID, city, zip, street, houseNumber, apartmentNumber) 
        VALUES (@userID, @countryID, @city, @zip, @street, @houseNumber, @apartmentNumber)
        SET @studentID = SCOPE_IDENTITY();
    END TRY
    BEGIN CATCH
        DELETE FROM Users WHERE userID = @userID
        RAISERROR ('Niepoprawne Dane!', 16, 1);
    end catch
    PRINT CONCAT('ID studenta: ', @studentID)
    RETURN @studentID;
END;
go
```

## Dodawanie Studiów - Jakub Fabia

```sql
CREATE PROCEDURE AddStudy
    @name VARCHAR(50),
    @description VARCHAR(200),
    @price MONEY,
    @capacity INT
AS
BEGIN
    DECLARE @ProductID INT;
    DECLARE @studyID INT;

    IF (@price <= 0)
        BEGIN
            RAISERROR ('Cena studiów musi być większa niż 0.', 16, 1);
        END
    IF (@capacity <= 0)
        BEGIN
            RAISERROR ('Pojemność studiów musi być większa niż 0.', 16, 1);
        END

    INSERT INTO Products (price, name, description) VALUES
    (@price, @name, @description);

    SET @ProductID = SCOPE_IDENTITY()

    -- Dodawanie nowego kursu z określoną pojemnością
    INSERT INTO Studies (productID, capacity)
    VALUES (@productID, @capacity);

    SET @studyID = SCOPE_IDENTITY()

    PRINT 'Studia dodane pomyślnie!';
    PRINT 'Detale:';
    PRINT CONCAT('Numer produktu: ', @ProductID);
    PRINT CONCAT('Numer studiów: ', @studyID);
    RETURN @studyID;
END;
go
```

## Dodawanie Przedmiotu do Studiów - Jakub Fabia

```sql
CREATE PROCEDURE AddSubject
    @studyID INT,
    @subjectCoordinatorID INT,
    @subjectName VARCHAR(50),
    @semester INT,
    @syllabusLink VARCHAR(400) = NULL
AS
BEGIN
    DECLARE @subjectID INT;
    -- Sprawdzenie czy studia istnieją
    IF NOT EXISTS (SELECT 1 FROM Studies WHERE studyID = @studyID)
        BEGIN
            RAISERROR ('ID studiów nie istnieje.', 16, 1);
            RETURN;
        END

    -- Sprawdzenie czy koordynator istnieje
    IF NOT EXISTS (SELECT 1 FROM Employees WHERE employeeID = @subjectCoordinatorID)
        BEGIN
            RAISERROR ('ID pracownika nie istnieje.', 16, 1);
            RETURN;
        END
    -- Sprawdzenie czy koordynator ma przypisaną rolę 'Koordynator Studiów'
    IF NOT EXISTS (
        SELECT 1
        FROM EmployeeRole ER
                 INNER JOIN Roles R ON ER.roleID = R.roleID
        WHERE ER.employeeID = @subjectCoordinatorID AND (R.roleName = 'Koordynator Studiów'  OR R.roleName = 'Koordynator Przedmiotu')
    )
        BEGIN
            RAISERROR ('Pracownik nie ma przypisanej roli Koordynator Przedmiotu.', 16, 1);
            RETURN;
        END
    IF @syllabusLink IS NULL
        BEGIN
            SET @syllabusLink = CONCAT('https://www.kaite.edu.pl/Syllabus/', @studyID, @semester, @subjectCoordinatorID)
        end
    -- Dodawanie przedmiotu
    INSERT INTO Subjects (studyID, subjectCoordinatorID, subjectName, syllabusLink, semester)
    VALUES (@studyID, @subjectCoordinatorID, @subjectName, @syllabusLink, @semester);
    SET @subjectID = SCOPE_IDENTITY();

    PRINT 'Przedmiot dodany pomyślnie do studiów!';
    PRINT 'Detale:';
    PRINT CONCAT('Numer studiów: ', @studyID);
    PRINT CONCAT('Numer przedmiotu: ', @subjectID);
END;
GO
```

## Dodawanie Spotkania do Przedmiotu - Jakub Fabia

```sql
CREATE PROCEDURE AddSubjectMeeting
    @subjectID INT,
    @price MONEY,
    @name VARCHAR(50),
    @description VARCHAR(200),
    @capacity INT,
    @Type VARCHAR(15),
    @teacherID INT,
    @startDatetime DATETIME,
    @duration TIME,
    @TranslatorID INT = NULL,
    @languageID INT = NULL,
    @roomID INT = NULL
AS
BEGIN
    DECLARE @StudyID INT;
    DECLARE @productID INT;
    DECLARE @meetingID INT;
    SET @StudyID = (SELECT studyID FROM Subjects WHERE subjectID = @subjectID)
    IF @capacity > (SELECT capacity FROM Studies WHERE studyID = @StudyID)
        Begin
            RAISERROR ('Pojemność spotkania musi być większa niż pojemność studiów.', 16, 1);
        end
    INSERT INTO Products (price, name, description) VALUES (@price, @name, @description)
    SET @productID = SCOPE_IDENTITY();
    
    EXEC @meetingID = AddMeetingWithDetails @teacherID, @startDatetime, @duration, @Type, @roomID, @capacity, NULL, NULL, @TranslatorID, @languageID

    INSERT INTO SubjectMeeting (meetingID, subjectID, productID, capacity) VALUES (@meetingID, @subjectID, @productID, @capacity)
    PRINT 'Spotkanie dodany pomyślnie do przedmiotu!';
    PRINT 'Detale:';
    PRINT CONCAT('Numer przedmiotu: ', @subjectID);
    PRINT CONCAT('Numer spotkania: ', @meetingID)
    END;
GO
```

## Dodawanie Tłumacza do Spotkania - Seweryn Tasior

```sql
CREATE PROCEDURE AddTranslator
    @meetingID INT,
    @translatorID INT,
    @languageID INT
AS
BEGIN
    -- Sprawdzenie czy spotkanie istnieje
    IF NOT EXISTS (SELECT 1 FROM Meetings WHERE meetingID = @meetingID)
        BEGIN
            RAISERROR ('Niepoprawne ID spotkania!', 16, 1);
        end
    -- Sprawdzenie czy tłumacz istnieje
    IF NOT EXISTS (SELECT 1 FROM Employees WHERE employeeID = @translatorID)
        BEGIN
            RAISERROR ('Niepoprawne ID tłumacza!', 16, 1);
        end
    -- Sprawdzenie czy język istnieje
    IF NOT EXISTS (SELECT 1 FROM Languages WHERE languageID = @languageID)
        BEGIN
            RAISERROR ('Niepoprawny język!', 16, 1);
        end
    IF NOT EXISTS (SELECT 1 FROM EmployeeLanguages WHERE employeeID = @TranslatorID AND languageID = @languageID)
        BEGIN
            RAISERROR ('Tłumacz nie mówi w tym języku!', 16, 1);
        end
    -- Wstawianie nowego tłumacza
    INSERT INTO Translators (meetingID, translatorID, languageID)
    VALUES (@meetingID, @translatorID, @languageID);
END;
GO
```

## Dodawanie Webinaru - Mariusz Krause

```sql
CREATE PROCEDURE AddWebinar
    @name VARCHAR(50),
    @description VARCHAR(200),
    @price MONEY,
    @Type VARCHAR(15),
    @teacherID INT,
    @startDatetime DATETIME,
    @duration TIME,
    @TranslatorID INT = NULL,
    @languageID INT = NULL
AS
BEGIN
    BEGIN TRY
        DECLARE @meetingID INT;
        DECLARE @productID INT;
        DECLARE @webinarID INT;

        IF @Type NOT IN ('OnlineSync', 'OnlineAsync')
            THROW 60012, 'Wrong meeting type.', 1;
        
        INSERT INTO Products (price, name, description) VALUES (@price, @name, @description);
        SET @productID = SCOPE_IDENTITY();
        
        EXEC @meetingID = AddMeetingWithDetails @teacherID, @startDatetime, @duration, @Type, NULL, NULL, NULL, NULL, @TranslatorID, @languageID
        
        INSERT INTO Webinars (productID, meetingID) VALUES (@productID, @meetingID)
        SET @webinarID = SCOPE_IDENTITY();
        PRINT CONCAT('WebinarID: ', @webinarID)
        RETURN @productID
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
```