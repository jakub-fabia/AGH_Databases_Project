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

with open('AGH_Databases_Project/tworzenie-danych/webinarsData.json', 'r') as file:
    data = json.load(file)

for webinar in data['webinars']:
    name = webinar['name']
    desc = webinar['description']
    price = webinar['price']
    if random.randint(1,2) == 1:
        webinarType = 'OnlineSync'
    else:
        webinarType = 'OnlineAsync'
    cursor.execute('''EXEC zInitialWebinarWithOrders ?,?,?,?''', (name, desc, price, webinarType))
cursor.commit()
