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

with open('AGH_Databases_Project/tworzenie-danych/webinarsData.json', 'r') as file:
    data = json.load(file)

# print(len(data['webinars']))

# for webinar in data['webinars']:
#     name = webinar['name']
#     desc = webinar['description']
#     price = webinar['price']
#     if random.randint(1,2) == 1:
#         webinarType = 'OnlineSync'
#     else:
#         webinarType = 'OnlineAsync'
#     cursor.execute('''EXEC GenerateWebinarWithOrders ?,?,?,?''', (name, desc, price, webinarType))
# cursor.commit()

# 3494-6922