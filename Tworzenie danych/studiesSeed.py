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
with open('studiesData.json', 'r') as file:
    data = json.load(file)


START_YEAR = 2020

