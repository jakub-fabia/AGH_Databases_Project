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

## Usuwanie zamówienia i jego szczegółów

```sql
CREATE PROCEDURE DeleteOrder
    @orderID INT
AS
BEGIN
    -- Sprawdzenie czy zamówienie istnieje
    IF NOT EXISTS (SELECT 1 FROM Orders WHERE orderID = @orderID)
        BEGIN
            RAISERROR ('ID zamówienia nie istnieje.', 16, 1);
            RETURN;
        END

    -- Wywołanie procedury usuwania szczegółów zamówienia
    DELETE FROM OrderDetails WHERE orderID = @orderID;
    -- Usuwanie zamówienia
    DELETE FROM Orders WHERE orderID = @orderID;
END;
go
```

## Dodawanie nowego kursu

```sql
CREATE PROCEDURE AddCourse
    @productID INT,
    @coordinatorID INT,
    @capacity INT
AS
BEGIN
    -- Sprawdzenie czy produkt jest już przypisany do innych tabel
    IF EXISTS (SELECT 1 FROM Studies WHERE productID = @productID)
        BEGIN
            RAISERROR (N'Produkt jest już przypisany do studiów.', 16, 1);
            RETURN;
        END

    IF EXISTS (SELECT 1 FROM Webinars WHERE productID = @productID)
        BEGIN
            RAISERROR ('Produkt jest już przypisany do webinaru.', 16, 1);
            RETURN;
        END

    -- Sprawdzenie czy produkt istnieje w tabeli Products
    IF NOT EXISTS (SELECT 1 FROM Products WHERE productID = @productID)
        BEGIN
            RAISERROR ('ID produktu nie istnieje.', 16, 1);
            RETURN;
        END

    -- Sprawdzenie czy koordynator istnieje w tabeli Employees
    IF NOT EXISTS (SELECT 1 FROM Employees WHERE employeeID = @coordinatorID)
        BEGIN
            RAISERROR ('ID koordynatora nie istnieje.', 16, 1);
            RETURN;
        END
    -- Sprawdzenie czy koordynator ma przypisaną rolę 'Koordynator Kursów'
    IF NOT EXISTS (
        SELECT 1
        FROM EmployeeRole ER
                 INNER JOIN Roles R ON ER.roleID = R.roleID
        WHERE ER.employeeID = @coordinatorID AND ( R.roleName = 'Koordynator Kursów' OR R.roleName = 'Koordynator')
    )
        BEGIN
            RAISERROR (N'Pracownik nie ma przypisanej roli Koordynator Kursów.', 16, 1);
            RETURN;
        END
    -- Dodawanie nowego kursu z określoną pojemnością
    INSERT INTO Courses (productID, coordinatorID, capacity)
    VALUES (@productID, @coordinatorID, @capacity);
END;
go
```

## Dodawanie modułu do istniejącego kursu

```sql
CREATE PROCEDURE AddCourseModule
    @courseID INT,
    @name VARCHAR(50)
AS
BEGIN
    -- Sprawdzenie czy kurs istnieje
    IF NOT EXISTS (SELECT 1 FROM Courses WHERE courseID = @courseID)
        BEGIN
            RAISERROR ('ID kursu nie istnieje.', 16, 1);
            RETURN;
        END

    -- Dodawanie modułu do kursu
    INSERT INTO CourseModules (courseID, name)
    VALUES (@courseID, @name);
END;
go

```

## Usuwanie kursu i jego modułów

```sql
CREATE PROCEDURE DeleteCourse
@courseID INT
AS
BEGIN
    -- Sprawdzenie czy kurs istnieje
    IF NOT EXISTS (SELECT 1 FROM Courses WHERE courseID = @courseID)
        BEGIN
            RAISERROR ('ID kursu nie istnieje.', 16, 1);
            RETURN;
        END

    -- Usuwanie wszystkich modułów kursu dla danego kursu
    DELETE FROM CourseModules WHERE courseID = @courseID;

    -- Usuwanie kursu
    DELETE FROM Courses WHERE courseID = @courseID;
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

## Usuwanie studiów i przedmiotów w jego ramach

```sql
CREATE PROCEDURE DeleteStudy
    @studyID INT
AS
BEGIN
    -- Sprawdzenie czy studia istnieją
    IF NOT EXISTS (SELECT 1 FROM Studies WHERE studyID = @studyID)
        BEGIN
            RAISERROR ('ID studiów nie istnieje.', 16, 1);
            RETURN;
        END

    -- Usuwanie wszystkich przedmiotów dla danych studiów
    DELETE FROM Subjects WHERE studyID = @studyID;

    -- Usuwanie studiów
    DELETE FROM Studies WHERE studyID = @studyID;
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

## Usuwanie webinaru

```sql
CREATE PROCEDURE DeleteWebinar
@webinarID INT
AS
BEGIN
    BEGIN TRANSACTION;

    IF EXISTS (SELECT 1 FROM Webinars WHERE webinarID = @webinarID)
        BEGIN
            DELETE FROM Webinars WHERE webinarID = @webinarID;
            COMMIT TRANSACTION;
        END
    ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            RAISERROR ('Webinar record not found.', 16, 1);
        END
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

## Usuwanie stażu

```sql
CREATE PROCEDURE DeleteInternship
@internshipID INT
AS
BEGIN
    BEGIN TRANSACTION;

    IF EXISTS (SELECT 1 FROM Internships WHERE internshipID = @internshipID)
        BEGIN
            DELETE FROM Internships WHERE internshipID = @internshipID;
            COMMIT TRANSACTION;
        END
    ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            RAISERROR ('Internship record not found.', 16, 1);
        END
END;
go

```

## Dodawanie studenta

```sql
CREATE PROCEDURE AddStudent
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


```

## Usuwanie studenta

```sql
CREATE PROCEDURE DeleteStudent
@studentID INT
AS
BEGIN
    BEGIN TRANSACTION;

    IF EXISTS (SELECT 1 FROM Students WHERE studentID = @studentID)
        BEGIN
            DELETE FROM Students WHERE studentID = @studentID;
            COMMIT TRANSACTION;
        END
    ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            RAISERROR ('Student record not found.', 16, 1);
        END
END;
go

```

## Dodawanie nowego tłumacza

```sql
CREATE PROCEDURE AddTranslator
    @meetingID INT,
    @translatorID INT,
    @languageID INT
AS
BEGIN
    BEGIN TRY
        -- Sprawdzenie czy spotkanie istnieje
        IF NOT EXISTS (SELECT 1 FROM Meetings WHERE meetingID = @meetingID)
            THROW 60008, 'MeetingID does not exist.', 1;

        -- Sprawdzenie czy tłumacz istnieje
        IF NOT EXISTS (SELECT 1 FROM Employees WHERE employeeID = @translatorID)
            THROW 60009, 'TranslatorID does not exist.', 1;

        -- Sprawdzenie czy język istnieje
        IF NOT EXISTS (SELECT 1 FROM Languages WHERE languageID = @languageID)
            THROW 60010, 'LanguageID does not exist.', 1;

        -- Wstawianie nowego tłumacza
        INSERT INTO Translators (meetingID, translatorID, languageID)
        VALUES (@meetingID, @translatorID, @languageID);
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

## Usuwanie tłumacza

```sql
CREATE PROCEDURE DeleteTranslator
@meetingID INT
AS
BEGIN
    BEGIN TRANSACTION;

    IF EXISTS (SELECT 1 FROM Translators WHERE meetingID = @meetingID)
        BEGIN
            DELETE FROM Translators WHERE meetingID = @meetingID;
            COMMIT TRANSACTION;
        END
    ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            RAISERROR ('Translator record not found.', 16, 1);
        END
END;
go

```

## Dodawanie pracownika

```sql
CREATE PROCEDURE AddEmployee
    @userID INT,
    @phone VARCHAR(20),
    @hireDate DATE = NULL,
    @isEmployed BIT = 1
AS
BEGIN
    BEGIN TRY
        -- Sprawdzenie czy użytkownik istnieje
        IF NOT EXISTS (SELECT 1 FROM Users WHERE userID = @userID)
            THROW 60011, 'UserID does not exist.', 1;

        -- Ustawienie domyślnej daty zatrudnienia, jeśli nie została podana
        IF @hireDate IS NULL
            SET @hireDate = GETDATE();

        -- Wstawianie nowego pracownika
        INSERT INTO Employees (userID, phone, hireDate, isEmployed)
        VALUES (@userID, @phone, @hireDate, @isEmployed);
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

## Usuwanie pracownika

```sql
CREATE PROCEDURE DeleteEmployee
@employeeID INT
AS
BEGIN
    BEGIN TRANSACTION;

    IF EXISTS (SELECT 1 FROM Employees WHERE employeeID = @employeeID)
        BEGIN
            DELETE FROM Employees WHERE employeeID = @employeeID;
            COMMIT TRANSACTION;
        END
    ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            RAISERROR ('Employee record not found.', 16, 1);
        END
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
