# Triggery

## Zmień dostępność produktu, jeśli jest już po jego rozpoczęciu - Jakub Fabia

```sql
CREATE TRIGGER trg_MakeProductUnavailable
ON [dbo].Products
AFTER INSERT, UPDATE
AS
BEGIN
    UPDATE Products
    SET isAvailable = 0
    WHERE productId IN (SELECT productID FROM ProductBeginningDate WHERE minStartTime <= CAST(GETDATE() AS DATE));
END;
go
```