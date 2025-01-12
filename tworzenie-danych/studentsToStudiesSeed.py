import pyodbc
import json
import random
import uuid
from datetime import datetime, timedelta
import os

print(os.getcwd())

conn = pyodbc.connect(
    "DRIVER={ODBC Driver 18 for SQL Server};"
    "SERVER={dbmanage.lab.ii.agh.edu.pl};"
    "DATABASE={u_fabia};"
    "UID={u_fabia};"
    "PWD={urtyQqKiDUJH};"
    "TrustServerCertificate=yes"
)
cursor = conn.cursor()

with open('tworzenie-danych/studiesData.json', 'r') as file:
    data = json.load(file)

taken_students = set()
studyId = 10
kierunek = data['majors'][studyId-1]
for ammount in range(int(kierunek['capacity']/2)):
    studentID = random.randint(5900, 6100)
    while studentID in taken_students:
        studentID = random.randint(5900, 6100)
    taken_students.add(studentID)
    cursor.execute('''EXEC InsertFutureStudent ?, ?''', (studyId, studentID))

cursor.commit()