CREATE TABLE Users (
    userID int NOT NULL IDENTITY(1,1),
    firstName varchar(20) NOT NULL,
    lastName varchar(20) NOT NULL,
    email varchar(50) NOT NULL,
    password varchar(50) NOT NULL,
    CONSTRAINT unique_email UNIQUE (email),
    CONSTRAINT email_format CHECK (
        email LIKE '%_@_%._%'
    ),
    CONSTRAINT userID PRIMARY KEY (userID)
);

CREATE TABLE Employees (
    employeeID int NOT NULL IDENTITY(1,1),
    userID int NOT NULL,
    phone varchar(15) NOT NULL,
    hireDate date NOT NULL DEFAULT GETDATE(),
    isEmployed bit NOT NULL DEFAULT 1,
    CONSTRAINT unique_phone UNIQUE (phone),
    CONSTRAINT valid_phone CHECK (
        (LEN(phone) = 9 AND ISNUMERIC(phone) = 1) OR
        (LEN(phone) > 9 AND LEFT(phone, 1) = '+' AND ISNUMERIC(SUBSTRING(phone, 2, LEN(phone))) = 1)
    ),
    CONSTRAINT Employees_Users FOREIGN KEY (userID) REFERENCES Users (userID),
    CONSTRAINT employeeID PRIMARY KEY (employeeID)
);

CREATE TABLE Countries (
    countryID int NOT NULL IDENTITY(1,1),
    countryName varchar(20) NOT NULL,
    CONSTRAINT Countries_pk PRIMARY KEY (countryID)
);

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
    CONSTRAINT Students_Users FOREIGN KEY (userID) REFERENCES Users (userID),
    CONSTRAINT Students_Countries FOREIGN KEY (countryID) REFERENCES Countries (CountryID),
    CONSTRAINT Students_pk PRIMARY KEY (studentID)
);

CREATE TABLE Languages (
    languageID int NOT NULL IDENTITY(1,1),
    languageName varchar(20) NOT NULL,
    CONSTRAINT Languages_pk PRIMARY KEY (languageID)
);

CREATE TABLE EmployeeLanguages (
    employeeID int NOT NULL,
    languageID int NOT NULL,
    CONSTRAINT TranslatorsLanguages_Employees FOREIGN KEY (employeeID) REFERENCES Employees (employeeID),
    CONSTRAINT Languages_TranslatorsLanguages FOREIGN KEY (languageID) REFERENCES Languages (languageID),
    CONSTRAINT EmployeeLanguages_pk PRIMARY KEY (employeeID,languageID)
);

CREATE TABLE Roles (
    roleID int NOT NULL IDENTITY(1,1),
    roleName varchar(30) NOT NULL,
    description varchar(200) NOT NULL,
    CONSTRAINT roleID PRIMARY KEY (roleID)
);

CREATE TABLE EmployeeRole (
    roleID int NOT NULL,
    employeeID int NOT NULL,
    CONSTRAINT EmployeeRole_Employees FOREIGN KEY (employeeID) REFERENCES Employees (employeeID),
    CONSTRAINT EmployeeRole_Roles FOREIGN KEY (roleID) REFERENCES Roles (roleID),
    CONSTRAINT EmployeeRole_pk PRIMARY KEY (roleID,employeeID)
);