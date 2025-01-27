USE u_fabia;
SET NOCOUNT ON;

DECLARE @UserId INT;
DECLARE @StudentId INT;

BEGIN TRANSACTION; -- Rozpoczęcie transakcji
BEGIN TRY
    --dodawanie studenta
    EXEC AddStudent 'Michal', N'Wącholski', 'mich.wach@interia.pl',
         33, 'Warszawa', '00-781',
         'Bagatela', '531A', '121'

    SELECT * FROM Products JOIN Studies oN Products.productID = Studies.productID WHERE Studies.productID=10;
    -- Dodanie zamówienia
    EXEC AddOrder
         @studentID = 7114,
         @paymentLink = 'https://www.kaite.edu.pl/PaymentLink/.....',
         @productID =10,
         @statusID = 1,
         @pricePaid = 200.00;

    -- Proba powtornego dodania zamówienia
    EXEC AddOrder
         @studentID = 7114,
         @paymentLink = 'https://www.kaite.edu.pl/PaymentLink/.....',
         @productID =10,
         @statusID = 1,
         @pricePaid = 200.00;

    -- Sprawdzenie wyniku
    SELECT * FROM Attendence WHERE studentID = 7114;

    --Szukamy takich studiow ktore sa pelne
    SELECT * FROM Products JOIN Studies oN Products.productID = Studies.productID WHERE (SELECT COUNT(*) FROM OrderDetails od WHERE od.productID=Products.productID)>=Studies.capacity;

    -- Dodanie zamówienia
    EXEC AddOrder
         @studentID = 7114,
         @paymentLink = 'https://www.kaite.edu.pl/PaymentLink/.....',
         @productID =1,
         @statusID = 1,
         @pricePaid = 200.00;


    COMMIT TRANSACTION;
    PRINT 'Transakcja zakończona pomyślnie.';
END TRY
BEGIN CATCH
    -- Wycofanie transakcji w przypadku błędu
    ROLLBACK TRANSACTION;

    -- Wyświetlenie informacji o błędzie
    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    SELECT
        @ErrorMessage = ERROR_MESSAGE(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE();

    RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH;

USE u_fabia;
SET NOCOUNT ON;


DECLARE @UserId INT = (SELECT userID FROM Users WHERE email = 'HHHH.kowalski@example.com');
DECLARE @StudentId INT = (SELECT studentID FROM Students WHERE userID = @UserId);

-- Usunięcie danych z tabeli Students
DELETE FROM Students WHERE studentID = @StudentId;

-- Usunięcie danych z tabeli Users
DELETE FROM Users WHERE userID = @UserId;