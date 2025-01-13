import pyodbc
import json
import random

conn = pyodbc.connect(
    "DRIVER={ODBC Driver 18 for SQL Server};"
    "SERVER={};"
    "DATABASE={};"
    "UID={};"
    "PWD={};"
    "TrustServerCertificate=yes"
)
cursor = conn.cursor()

with open('tworzenie-danych/studiesData.json', 'r') as file:
    data = json.load(file)

# Studia były tworzone pojedyńczo żeby upewnić się:
# - Studenci nie studiują na wielu (potencjalnie kolidujących) studiach na raz,
# - zmieniam rok co było wygodniej robić ręcznie niż to przeliczać
# - używam odpowiednich procedur, jeśli studia:
#      - się zakończyły: zInitialPassedStudent lub zInitialDropoutStudent
#      - są w trakcie: zInitialNotPassingStudent, zInitialPassingStudent lub zInitialDropoutStudent
#      - są w przyszłości: zInitialFutureStudent

taken_students = set()
studyId = 10
kierunek = data['majors'][studyId-1]
for ammount in range(int(kierunek['capacity']/2)):
    studentID = random.randint(5900, 6100)
    while studentID in taken_students:
        studentID = random.randint(5900, 6100)
    taken_students.add(studentID)
    cursor.execute('''EXEC zInitialFutureStudent ?, ?''', (studyId, studentID))

cursor.commit()