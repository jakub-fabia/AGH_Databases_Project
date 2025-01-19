# Procedury

## Dodawanie zamówienia

```sql

CREATE PROCEDURE AddOrder
  @studentID INT,
  @paymentLink VARCHAR(400)
AS
BEGIN
    -- Sprawdzenie czy student istnieje
    IF NOT EXISTS (SELECT 1 FROM Students WHERE studentID = @studentID)
    BEGIN
        RAISERROR ('ID studenta nie istnieje.', 16, 1);
        RETURN;
    END

    -- Dodawanie nowego zamówienia
    INSERT INTO Orders (studentID, paymentLink)
    VALUES (@studentID, @paymentLink);
END;
```

## Dodawanie szczegółów zamówienia

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
go
```

## Dodawanie nowego kursu - Jakub Fabia

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
go
```

## Dodawanie modułu do istniejącego kursu - Jakub Fabia

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
go
```

## Dodanie spotkania do modułu - Jakub Fabia

```sql
CREATE PROCEDURE AddCourseModuleMeeting
    @ModuleID INT,
    @Type VARCHAR(15),
    @teacherID INT,
    @startDatetime DATETIME,
    @duration TIME,
    @TranslatorID INT = NULL,
    @languageID INT = NULL
AS
BEGIN
    DECLARE @meetingID INT;
    DECLARE @capacity INT;
    DECLARE @roomID INT;

    SET @capacity = (SELECT capacity FROM Courses JOIN dbo.CourseModules CM on Courses.courseID = CM.courseID WHERE moduleID = @ModuleID);

    IF @Type NOT IN ('Stationary', 'OnlineSync', 'OnlineAsync')
        BEGIN
            RAISERROR ('Niepoprawna nazwa typu spotkania! Poprawne nazwy: ''Stationary'', ''OnlineSync'', ''OnlineAsync''', 16, 1);
        end
    ELSE
        IF @Type = 'Stationary' AND @capacity IS NULL
            BEGIN
                RAISERROR ('Spotkania nie mogą być stacjonarne, ponieważ kurs nie ma pojemności.', 16, 1);
            end

    IF @startDatetime < GETDATE()
        BEGIN
            RAISERROR ('Niepoprawna data spotkania!', 16, 1);
        end

    IF @duration > '4:00:00'
        BEGIN
            RAISERROR ('Niepoprawna długość spotkania!', 16, 1);
        end
    -- Sprawdzenie czy kurs istnieje
    IF NOT EXISTS (SELECT 1 FROM CourseModules WHERE moduleID = @ModuleID)
        BEGIN
            RAISERROR ('ID Modułu nie istnieje.', 16, 1);
        END

    IF NOT EXISTS (SELECT 1 FROM EmployeeRole WHERE employeeID = @teacherID AND roleID = 6)
        BEGIN
            RAISERROR ('Niepoprawne ID Nauczyciela.', 16, 1);
        END
    IF @TranslatorID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM EmployeeRole WHERE employeeID = @TranslatorID AND roleID = 11)
        BEGIN
            RAISERROR ('Niepoprawne ID Tłumacza.', 16, 1);
        END

    INSERT INTO Meetings (teacherID) VALUES (@teacherID)

    SET @meetingID = SCOPE_IDENTITY()

    INSERT INTO CourseModuleMeeting (meetingID, moduleID) VALUES (@meetingID, @ModuleID);
    INSERT INTO TimeSchedule (meetingID, startTime, duration) VALUES (@meetingID, @startDatetime, @duration)
    IF @Type = 'Stationary'
        BEGIN
            SET @roomID = (SELECT TOP 1 locationName FROM Location
            EXCEPT
            SELECT locationName FROM RoomSchedule
            WHERE startTime BETWEEN @startDatetime AND DATEADD(SECOND, DATEDIFF(SECOND, '00:00:00', @duration), @startDatetime) AND endTime BETWEEN @startDatetime AND DATEADD(SECOND, DATEDIFF(SECOND, '00:00:00', @duration), @startDatetime));
            INSERT INTO StationaryMeetings (meetingID, locationID) VALUES (@meetingID, @roomID)
        end
    IF @Type = 'OnlineSync'
        BEGIN
            INSERT INTO OnlineSyncMeetings (meetingID, recordingLink, liveMeetingLink) VALUES (@meetingID, CONCAT('https://www.kaite.edu.pl/RecordingLink/', @meetingID), CONCAT('https://www.kaite.edu.pl/MeetingLink/', @meetingID))
        end
    IF @Type = 'OnlineAsync'
        BEGIN
            INSERT INTO OnlineAsyncMeetings (meetingID, recordingLink) VALUES (@meetingID, CONCAT('https://www.kaite.edu.pl/RecordingLink/', @meetingID))
        end
    IF @TranslatorID IS NOT NULL
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM EmployeeLanguages WHERE employeeID = @TranslatorID AND languageID = @languageID)
                BEGIN
                    RAISERROR ('Niepoprawny język. Nie dodaję tłumacza!', 0, 1);
                end
            ELSE
                BEGIN
                    INSERT INTO Translators (meetingID, translatorID, languageID) VALUES (@meetingID, @TranslatorID, @languageID)
                END
        END
    PRINT 'Spotkanie pomyślnie dodane do modułu!';
    PRINT 'Detale:';
    PRINT CONCAT('Numer modułu: ', @ModuleID);
    PRINT CONCAT('Numer spotkania: ', @meetingID);
    PRINT CONCAT('Miejsce spotkania: ', @roomID)
END;
go
```


## Dodawanie studiów

```sql
CREATE PROCEDURE AddStudy
    @productID INT,
    @capacity INT
AS
BEGIN
    -- Sprawdzenie czy produkt istnieje
    IF NOT EXISTS (SELECT 1 FROM Products WHERE productID = @productID)
        BEGIN
            RAISERROR ('ID produktu nie istnieje.', 16, 1);
            RETURN;
        END

    -- Sprawdzenie czy produkt jest już przypisany do kursu
    IF EXISTS (SELECT 1 FROM Courses WHERE productID = @productID)
        BEGIN
            RAISERROR (N'Produkt jest już przypisany do kursu.', 16, 1);
            RETURN;
        END

    -- Sprawdzenie czy produkt jest już przypisany do webinaru
    IF EXISTS (SELECT 1 FROM Webinars WHERE productID = @productID)
        BEGIN
            RAISERROR (N'Produkt jest już przypisany do webinaru.', 16, 1);
            RETURN;
        END


    -- Dodawanie studiów
    INSERT INTO Studies (productID, capacity)
    VALUES (@productID, @capacity);
END;
go

```

## Dodawanie przedmiotów w ramach studiów

```sql
CREATE PROCEDURE AddSubject
    @studyID INT,
    @subjectCoordinatorID INT,
    @subjectName VARCHAR(50),
    @syllabusLink VARCHAR(400)
AS
BEGIN
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
        WHERE ER.employeeID = @subjectCoordinatorID AND (R.roleName = 'Koordynator Studiów'  OR R.roleName = 'Koordynator')
    )
        BEGIN
            RAISERROR ('Pracownik nie ma przypisanej roli Koordynator Studiów.', 16, 1);
            RETURN;
        END
    -- Dodawanie przedmiotu
    INSERT INTO Subjects (studyID, subjectCoordinatorID, subjectName, syllabusLink)
    VALUES (@studyID, @subjectCoordinatorID, @subjectName, @syllabusLink);
END;
go
```

## Dodawanie webinaru

```sql
CREATE PROCEDURE AddWebinar
    @productID INT,
    @meetingID INT
AS
BEGIN
    BEGIN TRY
        -- Sprawdzenie czy produkt istnieje
        IF NOT EXISTS (SELECT 1 FROM Products WHERE productID = @productID)
            THROW 60012, 'ProductID does not exist.', 1;

        -- Sprawdzenie czy spotkanie istnieje
        IF NOT EXISTS (SELECT 1 FROM Meetings WHERE meetingID = @meetingID)
            THROW 60013, 'MeetingID does not exist.', 1;

        -- Wstawianie nowego webinaru
        INSERT INTO Webinars (productID, meetingID)
        VALUES (@productID, @meetingID);
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

## Dodawanie spotkań do przedmiotów

```sql
CREATE PROCEDURE AddSubjectMeeting
    @meetingID INT,
    @subjectID INT,
    @productID INT,
    @capacity INT
AS
BEGIN
    BEGIN TRY
        -- Sprawdzenie, czy podany meetingID istnieje
        IF NOT EXISTS (SELECT 1 FROM Meetings WHERE meetingID = @meetingID)
            THROW 60001, 'MeetingID does not exist.', 1;

        -- Sprawdzenie, czy podany subjectID istnieje
        IF NOT EXISTS (SELECT 1 FROM Subjects WHERE subjectID = @subjectID)
            THROW 60002, 'SubjectID does not exist.', 1;

        -- Sprawdzenie, czy podany productID istnieje
        IF NOT EXISTS (SELECT 1 FROM Products WHERE productID = @productID)
            THROW 60003, 'ProductID does not exist.', 1;

        -- Sprawdzenie, czy produkt jest przypisany do studiów
        IF EXISTS (SELECT 1 FROM Studies WHERE productID = @productID)
            THROW 60004, 'Product is already assigned to a study.', 1;

        -- Sprawdzenie, czy produkt jest przypisany do kursu
        IF EXISTS (SELECT 1 FROM Courses WHERE productID = @productID)
            THROW 60005, 'Product is already assigned to a course.', 1;

        -- Sprawdzenie, czy produkt jest przypisany do webinaru
        IF EXISTS (SELECT 1 FROM Webinars WHERE productID = @productID)
            THROW 60006, 'Product is already assigned to a webinar.', 1;

        -- Wstawienie rekordu do tabeli SubjectMeeting
        INSERT INTO SubjectMeeting (meetingID, subjectID, productID, capacity)
        VALUES (@meetingID, @subjectID, @productID, @capacity);
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
END;
go


```

## Dodawanie nowego stażu

```sql
CREATE PROCEDURE AddInternship
    @studyID INT,
    @meetingID INT
AS
BEGIN
    BEGIN TRY
        -- Sprawdzenie czy studia istnieją
        IF NOT EXISTS (SELECT 1 FROM Studies WHERE studyID = @studyID)
            THROW 60004, 'StudyID does not exist.', 1;

        -- Sprawdzenie czy spotkanie istnieje
        IF NOT EXISTS (SELECT 1 FROM Meetings WHERE meetingID = @meetingID)
            THROW 60005, 'MeetingID does not exist.', 1;

        -- Wstawianie nowego stażu
        INSERT INTO Internships (studyID, meetingID)
        VALUES (@studyID, @meetingID);
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

## Dodawanie studenta - Jakub Fabia

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
        INSERT INTO Users (firstName, lastName, email) VALUES (@firstName, @lastName, @email)
        SET @userID = SCOPE_IDENTITY();
        INSERT INTO Students (userID, countryID, city, zip, street, houseNumber, apartmentNumber) 
        VALUES (@userID, @countryID, @city, @zip, @street, @houseNumber, @apartmentNumber)
    END TRY
    BEGIN CATCH
        DELETE FROM Users WHERE userID = @userID
        RAISERROR ('Niepoprawne Dane!', 16, 1);
    end catch
END;
go
```

## Dodawanie nowego tłumacza - Jakub Fabia

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
go
```

## Dodawanie pracownika - Jakub Fabia

```sql
CCREATE PROCEDURE AddEmployee
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
go
```

## Dodawanie spotkań

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

        -- Sprawdzenie, czy teacherID istnieje
        IF NOT EXISTS (SELECT 1 FROM Employees WHERE employeeID = @teacherID)
            THROW 61001, 'TeacherID does not exist.', 1;

        -- Wstawienie rekordu do tabeli Meetings
        INSERT INTO Meetings (teacherID)
        VALUES (@teacherID);

        -- Pobranie ID utworzonego meetingu
        SET @meetingID = SCOPE_IDENTITY();

        -- Sprawdzenie poprawności startTime i duration
        IF @startTime < '2020-01-01'
            THROW 61002, 'StartTime must be after 2020-01-01.', 1;

        IF @duration < '00:15:00' OR @duration > '04:30:00'
            THROW 61003, 'Duration must be between 15 minutes and 4 hours 30 minutes.', 1;

        -- Dodanie harmonogramu spotkania
        INSERT INTO TimeSchedule (meetingID, startTime, duration)
        VALUES (@meetingID, @startTime, @duration);

        -- Obsługa typu spotkania

        -- Dodanie StationaryMeeting
        IF @meetingType = 'Stationary'
            BEGIN
                IF @locationID IS NULL
                    THROW 61004, 'LocationID is required for Stationary meetings.', 1;

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
                IF @recordingLink IS NULL OR @liveMeetingLink IS NULL
                    THROW 61007, 'RecordingLink and LiveMeetingLink are required for OnlineSync meetings.', 1;

                IF @recordingLink NOT LIKE 'https://www.kaite.edu.pl/RecordingLink/%'
                    THROW 61008, 'Invalid RecordingLink format.', 1;

                IF @liveMeetingLink NOT LIKE 'https://www.kaite.edu.pl/MeetingLink/%'
                    THROW 61009, 'Invalid LiveMeetingLink format.', 1;

                INSERT INTO OnlineSyncMeetings (meetingID, recordingLink, liveMeetingLink)
                VALUES (@meetingID, @recordingLink, @liveMeetingLink);
            END
            -- Dodanie OnlineAsyncMeeting
        ELSE IF @meetingType = 'OnlineAsync'
            BEGIN
                IF @recordingLink IS NULL
                    THROW 61010, 'RecordingLink is required for OnlineAsync meetings.', 1;

                IF @recordingLink NOT LIKE 'https://www.kaite.edu.pl/RecordingLink/%'
                    THROW 61011, 'Invalid RecordingLink format.', 1;

                INSERT INTO OnlineAsyncMeetings (meetingID, recordingLink)
                VALUES (@meetingID, @recordingLink);
            END
        ELSE
            THROW 61012, 'Invalid MeetingType. Valid values are: Stationary, OnlineSync, OnlineAsync.', 1;

        -- Opcjonalne dodanie tłumacza
        IF @translatorID IS NOT NULL AND @languageID IS NOT NULL
            BEGIN
                IF NOT EXISTS (SELECT 1 FROM Employees WHERE employeeID = @translatorID)
                    THROW 61013, 'TranslatorID does not exist.', 1;

                IF NOT EXISTS (SELECT 1 FROM Languages WHERE languageID = @languageID)
                    THROW 61014, 'LanguageID does not exist.', 1;

                INSERT INTO Translators (meetingID, translatorID, languageID)
                VALUES (@meetingID, @translatorID, @languageID);
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
END;
go


```
