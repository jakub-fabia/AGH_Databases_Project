import pyodbc
import json
import random
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

with open('AGH_Databases_Project/tworzenie-danych/coursesData.json', 'r') as file:
    data = json.load(file)

def generate_random_saturday(start_date, end_date):
    start = datetime.fromisoformat(start_date)
    end = datetime.fromisoformat(end_date)
    while True:
        random_date = start + timedelta(days=random.randint(0, (end - start).days))
        if random_date.weekday() == 5: 
            random_hour = random.randint(0, 23)
            random_date = random_date.replace(hour=random_hour, minute=0, second=0)
            return random_date

def generate_following_dates(start_date):
    months_to_add = random.randint(4, 6)
    new_date = start_date + timedelta(days=months_to_add * 30)  
    working_hour = random.randint(9, 17) 
    new_date = new_date.replace(hour=working_hour, minute=0, second=0)
    next_day = new_date + timedelta(days=1)
    next_saturday = next_day + timedelta(days=(5 - next_day.weekday()) % 7)
    next_sunday = next_saturday + timedelta(days=1)
    return (new_date, next_day, next_saturday, next_sunday)

start_date = '2022-08-01'
end_date = '2025-01-01'

courses = data['courses']

for course in courses:
    courseName = course['name']
    courseDesc = course['description']
    coursePrice = course['price']
    courseCapacity = course['capacity']
    if courseCapacity == None:
        courseCapacity = 0
    courseCoordinator = random.randint(42, 151)
    createdAt = generate_random_saturday(start_date, end_date)
    modules = course['modules']
    module1name = modules[0]['name']
    module1type = modules[0]['type']
    module1date, module2date, module3date, module4date = generate_following_dates(createdAt)
    module2name = modules[1]['name']
    module2type = modules[1]['type']
    module3name = modules[2]['name']
    module3type = modules[2]['type']
    module4name = modules[3]['name']
    module4type = modules[3]['type']
    cursor.execute('''EXEC zInitialCoursesWithModules ?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?''', 
        (courseName, courseDesc, coursePrice, courseCapacity, courseCoordinator, createdAt, 
        module1name, module1type, module1date,
        module2name, module2type, module2date,
        module3name, module3type, module3date,
        module4name, module4type, module4date))
cursor.commit()