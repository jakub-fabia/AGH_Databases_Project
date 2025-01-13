import pyodbc

conn = pyodbc.connect(
    "DRIVER={ODBC Driver 18 for SQL Server};"
    "SERVER={};"
    "DATABASE={};"
    "UID={};"
    "PWD={};"
    "TrustServerCertificate=yes"
)
cursor = conn.cursor()

roomId = 1

for i in range(1, 5):
    for j in range(1, 40):
        if len(str(j)) == 1:
            k = "0" + str(j)
        else:
            k = str(j)
        roomName = "Pokój: " + str(i) + k
        cursor.execute('''INSERT INTO Location (locationID,LocationName) VALUES (?, ?)''', (roomId, roomName))
        roomId += 1

cursor.commit()