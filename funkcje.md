# Funkcje

## Sprawdzenie czy tłumacz jest poprawny - Jakub Fabia

```sql
CREATE FUNCTION IsTranslatorValid (@translatorID INT, @languageID INT)
RETURNS BIT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM EmployeeRole WHERE employeeID = @TranslatorID AND roleID = 11)
        BEGIN
            RETURN 0;
        END
    IF NOT EXISTS (SELECT 1 FROM EmployeeLanguages WHERE employeeID = @TranslatorID AND languageID = @languageID)
        BEGIN
            RETURN 0;
        end
    RETURN 1;
end
go
```