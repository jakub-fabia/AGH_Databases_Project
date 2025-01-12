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
## Dodawanie spotkań do przedmiotów
## Dodawanie nowego stażu
## Dodawanie studenta
## Dodawanie nowego tłumacza
## Dodawanie pracownika
