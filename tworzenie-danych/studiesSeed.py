import pyodbc
import json
import random
import uuid
from datetime import datetime, timedelta

conn = pyodbc.connect(
    "DRIVER={ODBC Driver 18 for SQL Server};"
    "SERVER={};"
    "DATABASE={};"
    "UID={};"
    "PWD={};"
    "TrustServerCertificate=yes"
)
cursor = conn.cursor()

with open('AGH_Databases_Project/tworzenie-danych/studiesData.json', 'r') as file:
    data = json.load(file)

# Dodawanie studiów
for a in [8,9]:
    kierunek = data['majors'][a]
    nazwa = kierunek['major']
    opis = kierunek['description']
    cena = kierunek['price']
    capacity = kierunek['capacity']
    isAvailable = 1
    created = '2025-01-01 15:00:00'
    cursor.execute('''
        EXEC zInitialStudies
        ?, ?, ?, ?, ?, ?
    ''', (nazwa, opis, cena, capacity, isAvailable, created))
    cursor.commit()

# Dodawanie przedmiotów
for a in [8,9]:
    kierunek = data['majors'][a]
    studyid = a+1
    used_dates = set()
    capacity = kierunek['capacity']

    for semestr in kierunek['semesters']:
        semester = semestr['semester']
        for subject in semestr['subjects']:
            subjectCap = capacity + random.randint(0,5)
            name = subject['subject']
            desc = subject['description']
            liveLink = f'https://www.kaite.edu.pl/MeetingLink/{uuid.uuid4()}'
            recordingLink = f'https://www.kaite.edu.pl/RecordingLink/{uuid.uuid4()}'
            if random.randint(1, 10) != 7:
                isStacionary = 1
            else:
                if random.randint(1, 2) == 2:
                    isStacionary = 0
                else:
                    isStacionary = -1
            coordinator = random.randint(42, 86)

            if semester in [1, 2]:
                year = 2025
            elif semester in [3, 4]:
                year = 2026
            elif semester in [5, 6]:
                year = 2027
            else:
                year = 2028

            month = 10 if semester % 2 != 0 else 2

            start_datetime = datetime(year, month, 1)
            while start_datetime.weekday() not in [5, 6] or start_datetime in used_dates:  # Check for conflicts
                start_datetime += timedelta(days=1)

            used_dates.add(start_datetime)

            start_hour = random.choice([8, 10, 12, 14, 16, 18])
            start_datetime = start_datetime.replace(hour=start_hour, minute=0)

            syllabus = f'https://www.kaite.edu.pl/Syllabus/{uuid.uuid4()}'
            
            cursor.execute('''EXEC InsertSubjects ?,?,?,?,?,?,?,?,?,?,?''', (studyid, coordinator, name, syllabus, semester, start_datetime, desc, subjectCap,isStacionary,liveLink,recordingLink))
    cursor.commit()