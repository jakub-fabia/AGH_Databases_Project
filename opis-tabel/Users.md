# Kategoria Users

## Tabela Users

Tabela **Users** przechowuje podstawowe informacje o użytkownikach systemu:

- **userID** - id użytkownika (klucz główny, int)
  - autoinkrementacja: od wartości 1 , kolejna wartość większa o 1
- firstName - imię użytkownika (varchar(20))
- lastName - nazwisko użytkownika (varchar(20))
- email - adres email użytkownika (varchar(50))
  - warunek: Unikalny w formacie '%_@_%._%'

```sql
CREATE TABLE Users (
    userID int NOT NULL IDENTITY(1,1),
    firstName varchar(20) NOT NULL,
    lastName varchar(20) NOT NULL,
    email varchar(50) NOT NULL,
    CONSTRAINT unique_email UNIQUE (email),
    CONSTRAINT email_format CHECK (
        email LIKE '%_@_%._%'
    ),
    CONSTRAINT userID PRIMARY KEY (userID)
);
```

## Tabela Employees

Tabela **Employees** przechowuje informacje o pracownikach:

- **employeeID** - id pracownika (klucz główny, int)
  - autoinkrementacja: od wartości 1 , kolejna wartość większa o 1
- **userID** - id użytkownika (klucz obcy do Users, int)
- phone - numer telefonu pracownika (varchar(15))
  - warunek: Jeśli długość = 9 to wszystkie znaki muszą być cyframi (numery polskie). Jeśli jest dłuższy to na początku musi być +, a następne znaki to cyfry (kierunkowy i zagraniczne numery)
- hireDate - data zatrudnienia pracownika (date)
  - domyślnie: Dzisiejsza data
  - warunek: data między '2020-01-01', a datą dzisiejszą
- isEmployed - czy pracownik jest zatrudniony (bit)

```sql
CREATE TABLE Employees (
    employeeID int NOT NULL IDENTITY(1,1),
    userID int NOT NULL,
    phone varchar(15) NOT NULL,
    hireDate date NOT NULL DEFAULT GETDATE(),
    isEmployed bit NOT NULL DEFAULT 1,
    CONSTRAINT hireDate_Employees_reasonable CHECK (
        hireDate BETWEEN '2020-01-01' AND GETDATE()
    ),
    CONSTRAINT unique_phone UNIQUE (phone),
    CONSTRAINT valid_phone CHECK (
        (LEN(phone) = 9 AND ISNUMERIC(phone) = 1) OR
        (LEN(phone) > 9 AND LEFT(phone, 1) = '+' AND ISNUMERIC(SUBSTRING(phone, 2, LEN(phone))) = 1)
    ),
    CONSTRAINT Employees_Users FOREIGN KEY (userID) REFERENCES Users (userID),
    CONSTRAINT employeeID PRIMARY KEY (employeeID)
);
```

## Tabela Countries

Tabela **Countries** przechowuje informacje o krajach:

- **countryID** - id kraju (klucz główny, int)
  - autoinkrementacja: od wartości 1 , kolejna wartość większa o 1
- countryName - nazwa kraju (varchar(20))

```sql
CREATE TABLE Countries (
    countryID int NOT NULL IDENTITY(1,1),
    countryName varchar(20) NOT NULL,
    CONSTRAINT Countries_pk PRIMARY KEY (countryID)
);
```

## Tabela Students

Tabela **Students** przechowuje informacje o studentach:

- **studentID** - id studenta (klucz główny, int)
  - autoinkrementacja: od wartości 1 , kolejna wartość większa o 1
- **userID** - id użytkownika (klucz obcy do Users, int)
- countryID - id kraju zamieszkania (klucz obcy do Countries, int)
- city - miasto (varchar(20))
- zip - kod pocztowy (varchar(10))
- street - ulica (varchar(20))
- houseNumber - numer domu (varchar(5))
- apartmentNumber - numer mieszkania (varchar(7))
- registrationDate - data rejestracji (datetime)
  - domyślnie: data dzisiejsza
  - warunek: data rejestracji między '2020-01-01', a datą dzisiejszą

```sql
CREATE TABLE Students (
    studentID int NOT NULL IDENTITY(1,1),
    userID int NOT NULL,
    countryID int NOT NULL,
    city varchar(20) NOT NULL,
    zip varchar(10) NOT NULL,
    street varchar(20) NOT NULL,
    houseNumber varchar(5) NOT NULL,
    apartmentNumber varchar(7) NULL,
    registrationDate datetime NOT NULL DEFAULT GETDATE(),
    CONSTRAINT registrationDate_Students_reasonable CHECK (
        registrationDate BETWEEN '2020-01-01' AND GETDATE()
    ),
    CONsSTRAINT Students_Users FOREIGN KEY (userID) REFERENCES Users (userID),
    CONSTRAINT Students_Countries FOREIGN KEY (countryID) REFERENCES Countries (CountryID),
    CONSTRAINT Students_pk PRIMARY KEY (studentID)
);
```

## Tabela Languages

Tabela **Languages** przechowuje informacje o dostępnych językach wykładowych:

- **languageID** - id języka (klucz główny, int)
  - autoinkrementacja: od wartości 1 , kolejna wartość większa o 1
- languageName - nazwa języka (varchar(20))

```sql
CREATE TABLE Languages (
    languageID int NOT NULL IDENTITY(1,1),
    languageName varchar(20) NOT NULL,
    CONSTRAINT Languages_pk PRIMARY KEY (languageID)
);
```

## Tabela EmployeeLanguages

Tabela **EmployeeLanguage**s jest tabelą pomocniczą służącą do reprezentowania relacji wiele-do-wiele pomiędzy tabelami **Employee** i **Languages**:

- **employeeID** - id pracownika (klucz główny, klucz obcy do Employee, int)
- **languageID** - id języka (klucz główny, klucz obcy do Languages, int)

```sql
CREATE TABLE EmployeeLanguages (
    employeeID int NOT NULL,
    languageID int NOT NULL,
    CONSTRAINT TranslatorsLanguages_Employees FOREIGN KEY (employeeID) REFERENCES Employees (employeeID),
    CONSTRAINT Languages_TranslatorsLanguages FOREIGN KEY (languageID) REFERENCES Languages (languageID),
    CONSTRAINT EmployeeLanguages_pk PRIMARY KEY (employeeID,languageID)
);
```

## Tabela Roles

Tabela **Roles** przechowuje informacje o możliwych stanowiskach pracowniczych w systemie:

- **roleID** - id roli (klucz główny, int)
  - autoinkrementacja: od wartości 1 , kolejna wartość większa o 1
- roleName - nazwa roli (varchar(20))
- description - opis roli (varchar(200))

```sql
CREATE TABLE Roles (
    roleID int NOT NULL IDENTITY(1,1),
    roleName varchar(30) NOT NULL,
    description varchar(200) NOT NULL,
    CONSTRAINT roleID PRIMARY KEY (roleID)
);
```

## Tabela EmployeeRole

Tabela **EmployeeRole** jest tabelą pomocniczą służącą do reprezentowania relacji wiele-do-wiele pomiędzy tabelami **Employee** i **Role**. Pozwala na posiadanie wielu ról przez wielu pracowników:

- **roleID** - id roli (klucz główny, klucz obcy do Role, int)
- **employeeID** - id pracownika (klucz główny, klucz obcy do Employee, int)

```sql
CREATE TABLE EmployeeRole (
    roleID int NOT NULL,
    employeeID int NOT NULL,
    CONSTRAINT EmployeeRole_Employees FOREIGN KEY (employeeID) REFERENCES Employees (employeeID),
    CONSTRAINT EmployeeRole_Roles FOREIGN KEY (roleID) REFERENCES Roles (roleID),
    CONSTRAINT EmployeeRole_pk PRIMARY KEY (roleID,employeeID)
);
```
