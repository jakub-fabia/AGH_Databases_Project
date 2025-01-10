# Kategoria Orders

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
```
CREATE TABLE OrderStatus (
    statusID int NOT NULL IDENTITY(1,1),
    statusName varchar(40) NOT NULL,
    CONSTRAINT OrderStatus_pk PRIMARY KEY (statusID)
);
```
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
```sql
CREATE TABLE ShoppingCart (
    studentID int NOT NULL,
    productID int NOT NULL,
    CONSTRAINT Cart_Students FOREIGN KEY (studentID) REFERENCES Students (studentID),
    CONSTRAINT ShoppingCart_Products FOREIGN KEY (productID) REFERENCES Products (productID),
    CONSTRAINT ShoppingCart_pk PRIMARY KEY (studentID,productID)
);
```
```sql
CREATE TABLE OrderDetails (
    orderID int NOT NULL IDENTITY(1,1),
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