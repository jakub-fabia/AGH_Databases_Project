import pyodbc
import json
from faker import Faker
import random

 # Initialize DB connection
conn = pyodbc.connect(
    "DRIVER={ODBC Driver 18 for SQL Server};"
    "SERVER={dbmanage.lab.ii.agh.edu.pl};"
    "DATABASE={u_fabia};"
    "UID={u_fabia};"
    "PWD={urtyQqKiDUJH};"
    "TrustServerCertificate=yes"
)
cursor = conn.cursor()
fake = Faker('pl_PL')

# Te osoby mają tylko jedną rolę 
# dodane w specialUsers.sql
ADMIN = 1
DIRECTOR = 1
SECRETARY = 2
ACCOUNTANT = 2
PLANIST = 2
INTERNSHIP_MAN = 4
TRANSLATOR = 10 # dodane analogicznie do study_coordinator

STUDY_COORDINATOR = 10 # są też subject coordinator oraz teacher

for i in range(STUDY_COORDINATOR):
    phone = fake.phone_number().replace(" ", "")
    first_name = fake.first_name()
    last_name = fake.last_name()
    email = fake.ascii_free_email()
    hire_date = '2020-01-01'
    role_id1 = 10
    role_id2 = 6
    role_id3 = 9
    cursor.execute('''
        EXEC InsertEmployeeData 
        ?, ?, ?, ?, ?, ?, ?, ?
    ''', (first_name, last_name, email, phone, hire_date, role_id1, role_id2, role_id3))

cursor.commit()

SUBJECT_COORDINATOR = 100 # są też teacher

for i in range(SUBJECT_COORDINATOR):
    phone = fake.phone_number().replace(" ", "")
    first_name = fake.first_name()
    last_name = fake.last_name()
    email = fake.ascii_free_email()
    hire_date = '2020-01-01'
    role_id1 = 9
    role_id2 = 6
    cursor.execute('''
        EXEC InsertEmployeeData2 
        ?, ?, ?, ?, ?, ?, ?
    ''', (first_name, last_name, email, phone, hire_date, role_id1, role_id2))

cursor.commit()

TEACHER = 150 

for i in range(TEACHER):
    phone = fake.phone_number().replace(" ", "")
    first_name = fake.first_name()
    last_name = fake.last_name()
    email = fake.ascii_free_email()
    hire_date = '2020-01-01'
    role_id = 6
    cursor.execute('''
        EXEC InsertEmployeeData3 
        ?, ?, ?, ?, ?, ?
    ''', (first_name, last_name, email, phone, hire_date, role_id))

cursor.commit()


STUDENTS = 3000

# dla 2500 studentów użyto fakera polskiego i countryID polski (33)

rand = random.Random()
fake = Faker()

fake.unique.clear()

for i in range(500):
    apartmentNumber = None
    print(i)
    first_name = fake.first_name()
    last_name = fake.last_name()
    email = fake.unique.ascii_email()
    city = fake.city()
    zip = fake.zipcode()
    street = fake.street_name()
    houseNumber = fake.building_number()
    if houseNumber.__contains__("/"):
        numbers = houseNumber.split("/")
        houseNumber = numbers[0]
        apartmentNumber = numbers[1]
    cursor.execute('''
        EXEC InsertStudentData
        ?, ?, ?, ?, ?, ?, ?, ?, ?
    ''', (first_name, last_name, email, rand.randint(34, 69), city, zip, street, houseNumber, apartmentNumber))

cursor.commit()
