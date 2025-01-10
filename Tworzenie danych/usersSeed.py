import pyodbc
import json

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

# Read studiesData.json
with open('usersData.json', 'r') as file:
    data = json.load(file)

STUDENTS = 3000
EMPLOYEES = 282

# Te osoby mają tylko jedną rolę 
ADMIN = 1
DIRECTOR = 1
SECRETARY = 2
ACCOUNTANT = 2
PLANIST = 2
INTERNSHIP_MAN = 4
TRANSLATOR = 10 

STUDY_COORDINATOR = 10 # są też subject coordinator oraz teacher
SUBJECT_COORDINATOR = 100 # są też teacher
TEACHER = 150 