# Kategoria Orders

## Tabela Products

Tabela **Products** przechowuje informacje o produktach dostępnych w systemie:

- **productID** - id produktu (klucz główny, int)
  - autoinkrementacja: od wartości 1 , kolejna wartość większa o 1
- price - cena produktu (money)
    - warunek: cena większa lub równa 0
- name - nazwa produktu (varchar(50))
- description - opis produktu (varchar(200))
- createdAt - data utworzenia produktu (datetime)
  - warunek: data między '2020-01-01', a datą dzisiejszą
- isAvailable - dostępność produktu (bit)

```sql
CREATE TABLE Products (
    productID int NOT NULL IDENTITY(1,1),
    price money NOT NULL,
    name varchar(50) NOT NULL,
    description varchar(200) NOT NULL,
    createdAt datetime NOT NULL DEFAULT GETDATE(),
    isAvailable bit NOT NULL DEFAULT 1,
    CONSTRAINT createdAt_products_reasonable CHECK (
        createdAt BETWEEN '2020-01-01' AND GETDATE()
    ),
    CONSTRAINT price_nonnegative CHECK (
        price >= 0
    ),
    CONSTRAINT Products_pk PRIMARY KEY (productID)
);
```

## Tabela Certificates

Tabela **Certificates** przechowuje informacje o certyfikatach wydanych studentom:

- **certificateID** - id certyfikatu (klucz główny, int)
  - autoinkrementacja: od wartości 1 , kolejna wartość większa o 1
- **studentID** - id studenta (klucz obcy do Students, int)
- **productID** - id produktu (klucz obcy do Products, int)
- issuedAt - data wydania certyfikatu (datetime)
  - warunek: data między '2020-01-01', a datą dzisiejszą

```sql
CREATE TABLE Certificates (
    certificateID int NOT NULL IDENTITY(1,1),
    studentID int NOT NULL,
    productID int NOT NULL,
    issuedAt datetime NOT NULL,
    CONSTRAINT issuedAt_certificates_reasonable CHECK (
        issuedAt BETWEEN '2020-01-01' AND GETDATE()
    ),
    CONSTRAINT Certifactes_Products FOREIGN KEY (productID) REFERENCES Products (productID),
    CONSTRAINT Certifactes_Students FOREIGN KEY (studentID) REFERENCES Students (studentID),
    CONSTRAINT Certificates_pk PRIMARY KEY (certificateID)
);
```

## Tabela OrderStatus

Tabela **OrderStatus** przechowuje informacje o statusach każdego zamówionego przedmiotu:

- **statusID** - id statusu (klucz główny, int)
  - autoinkrementacja: od wartości 1 , kolejna wartość większa
- statusName - nazwa statusu (varchar(40))

```sql
CREATE TABLE OrderStatus (
    statusID int NOT NULL IDENTITY(1,1),
    statusName varchar(40) NOT NULL,
    CONSTRAINT OrderStatus_pk PRIMARY KEY (statusID)
);
```

## Tabela Orders

Tabela **Orders** przechowuje informacje o zamówieniach złożonych przez studentów:

- **orderID** - id zamówienia (klucz główny, int)
  - autoinkrementacja: od wartości 1 , kolejna wartość większa o 1
- **studentID** - id studenta składającego zamówienie (klucz obcy do Students, int)
- paymentLink - link do płatności (varchar(400))
  - warunek: link w formacie 'https://www.kaite.edu.pl/PaymentLink/%'
- createdAt - data utworzenia zamówienia (datetime)
  - warunek: data między '2020-01-01', a datą dzisiejszą

```sql
CREATE TABLE Orders (
    orderID int NOT NULL IDENTITY(1,1),
    studentID int NOT NULL,
    paymentLink varchar(400) NOT NULL,
    createdAt datetime NOT NULL DEFAULT GETDATE(),
    CONSTRAINT createdAt_orders_reasonable CHECK (
        createdAt BETWEEN '2020-01-01' AND GETDATE()
    ),
    CONSTRAINT valid_link_paymentLink CHECK (
        paymentLink LIKE 'https://www.kaite.edu.pl/PaymentLink/%'
    ),
    CONSTRAINT Students_Orders FOREIGN KEY (studentID) REFERENCES Students (studentID),
    CONSTRAINT Orders_pk PRIMARY KEY (orderID)
);
```

## Tabela ShoppingCart

Tabela **ShoppingCart** jest tabelą pomocniczą służącą do reprezentowania relacji wiele-do-wiele pomiędzy tabelami **Students** i **Products**. Przechowuje ona informacje o produktach w koszyku danego studenta (1 koszyk, wiele produktów):

- **studentID** - id studenta (klucz główny, klucz obcy do Students, int)
- **productID** - id produktu (klucz główny, klucz obcy do Products, int)

```sql
CREATE TABLE ShoppingCart (
    studentID int NOT NULL,
    productID int NOT NULL,
    CONSTRAINT Cart_Students FOREIGN KEY (studentID) REFERENCES Students (studentID),
    CONSTRAINT ShoppingCart_Products FOREIGN KEY (productID) REFERENCES Products (productID),
    CONSTRAINT ShoppingCart_pk PRIMARY KEY (studentID,productID)
);
```

## Tabela OrderDetails

Tabela **OrderDetails** przechowuje szczegółowe informacje o produktach w zamówieniach:

- **orderID** - id zamówienia (klucz główny, klucz obcy do Orders, int)
- **productID** - id produktu (klucz główny, klucz obcy do Products, int)
- **statusID** - id statusu zamówienia (klucz obcy do OrderStatus, int)
- **pricePaid** - kwota zapłacona za produkt (money)
    - Warunek: Nieujemna

```sql
CREATE TABLE OrderDetails (
    orderID int NOT NULL,
    productID int NOT NULL,
    statusID int NOT NULL,
    pricePaid money NOT NULL,
    CONSTRAINT order_item_price_nonnegative CHECK (
        pricePaid >= 0
    ),
    CONSTRAINT OrderItems_Orders FOREIGN KEY (orderID) REFERENCES Orders (orderID),
    CONSTRAINT OrderItems_Products FOREIGN KEY (productID) REFERENCES Products (productID),
    CONSTRAINT OrderDetails_OrderStatus FOREIGN KEY (statusID) REFERENCES OrderStatus (statusID),
    CONSTRAINT orderItemID PRIMARY KEY (orderID,productID)
);
```
