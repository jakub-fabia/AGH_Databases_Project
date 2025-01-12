# Kategoria Meetings
## Tabela Meetings
Tabela **Meetings** przechowuje informacje o spotkaniach:
- **meetingID** - id spotkania (klucz główny, int)
    - autoinkrementacja: od wartości 1 , kolejna wartość większa o 1
- teacherID - id nauczyciela prowadzącego spotkanie (klucz obcy,int)
```sql
CREATE TABLE Meetings (
    meetingID int NOT NULL IDENTITY(1,1),
    teacherID int NOT NULL,
    CONSTRAINT Meetings_Employees FOREIGN KEY (teacherID) REFERENCES Employees (employeeID),
    CONSTRAINT Meetings_pk PRIMARY KEY (meetingID)
);
```
## Tabela Attendance
Tabela **Attendance** przechowuje informacje o obecności studentów na spotkaniach.  Reprezentuje relację wiele-do-wiele pomiędzy tabelami Meetings i Students:
- **meetingID** - id spotkania (klucz główny, klucz obcy do Meetings, int)
- **studentID** - id studenta (klucz główny, klucz obcy do Students, int)
- present - status obecności studenta (bit)
    - wartość domyślna: 0 (brak obecności)
- makeUp - informacja czy zajęcia zostały odrobione (bit)
    - wartość domyślna: 0 (nie zostały odrobione)
```sql
CREATE TABLE Attendence (
    meetingID int NOT NULL,
    studentID int NOT NULL,
    present bit NOT NULL DEFAULT 0,
    makeUp bit NOT NULL DEFAULT 0,
    CONSTRAINT Attendence_Students FOREIGN KEY (studentID) REFERENCES Students (studentID),
    CONSTRAINT Meeting_Attendence FOREIGN KEY (meetingID) REFERENCES Meetings (meetingID),
    CONSTRAINT Attendence_pk PRIMARY KEY (meetingID,studentID)
);
```
## Tabela Time Schedule
Tabela **TimeSchedule** przechowuje informacje o harmonogramach spotkań (jeśli spotkanie potrzebuje harmonogramu):
- **meetingID** - id spotkania (klucz główny, klucz obcy do Meetings, int)
- startTime - czas rozpoczęcia spotkania (datetime)
    - warunek: musi być większa niż 1 stycznia 2020 roku
- duration  - czas trwannia spotkania (datetime)
    - wartość domyślna: 1 godzina 30 minut
    - warunek: czas trwania jest pomiędzy 15 minut a 4 godziny i 30 minut

```sql
CREATE TABLE TimeSchedule (
    meetingID int NOT NULL,
    startTime datetime NOT NULL,
    duration time NOT NULL DEFAULT '01:30:00',
    CONSTRAINT startTime_TimeSchedule_reasonable CHECK (
        startTime > '2020-01-01'
    ),
    CONSTRAINT duration_TimeSchedule_reasonable CHECK (
        duration BETWEEN '00:15:00' AND '04:30:00'
    ),
    CONSTRAINT TimeSchedule_Meeting FOREIGN KEY (meetingID) REFERENCES Meetings (meetingID),
    CONSTRAINT TimeSchedule_pk PRIMARY KEY (meetingID)
);
```
## Tabela Translators
Tabela **Translators** przechowuje informacje o tłumaczach na danych spotkaniach i językach ich tłumaczeń:
- **meetingID** - id spotkania (klucz główny, klucz obcy do Meetings, int)
- translatorID - id tłumacza (klucz obcy do Employees, int)
- languageID - id języka tłumaczenia (klucz obcy do Languages, int)

```sql
CREATE TABLE Translators (
    meetingID int NOT NULL,
    translatorID int NOT NULL,
    languageID int NOT NULL,
    CONSTRAINT Meeting_Translators FOREIGN KEY (meetingID) REFERENCES Meetings (meetingID),
    CONSTRAINT Employees_Translators FOREIGN KEY (translatorID) REFERENCES Employees (employeeID),
    CONSTRAINT Languages_Translators FOREIGN KEY (languageID) REFERENCES Languages (languageID),
    CONSTRAINT Translators_pk PRIMARY KEY (meetingID)
);
```
## Tabela InternshipMeetings 
Tabela **InternshipMeetings** jest tabelą do przechowywania informacji o stażach reprezentowana w relacji jeden-do-jeden z tabelą **Meetings**:
- **meetingID** - id spotkania (klucz główny, klucz obcy do Meetings, int)
    - warunek: musi być pomiędzy 1 stycznia 2020 roku a
    datą dzisiejszą
- startDate - data rozpoczęcia stażu (date)

```sql
CREATE TABLE InternshipMeetings (
    meetingID int NOT NULL,
    startDate date NOT NULL,
    CONSTRAINT startDate_InternshipMeetings_reasonable CHECK (
        startDate BETWEEN '2020-01-01' AND GETDATE()
    ),
    CONSTRAINT Meetings_InternshipMeeting FOREIGN KEY (meetingID) REFERENCES Meetings (meetingID),
    CONSTRAINT InternshipMeeting_pk PRIMARY KEY (meetingID)
);
```
# Tabela OnlineSyncMeetings 
Tabela **OnlineSyncMeetings** przechowuje informacje synchronicznych spotkaniach online:
- **meetingID** - id spotkania (klucz główny, klucz obcy do Meetings, int)
- recordingLink - link do nagrania spotkania (varchar(400))
    - warunek: link musi być URl-em zaczynającym się od https://www.kaite.edu.pl/RecordingLink/
- liveMettingLink - link do spotkanie na żywo (varchar(400))
    - warunek: link musi być URl-em zaczynającym się od https://www.kaite.edu.pl/MeetingLink/


```sql
CREATE TABLE OnlineSyncMeetings (
    meetingID int NOT NULL,
    recordingLink varchar(400) NOT NULL,
    liveMeetingLink varchar(400) NOT NULL,
    CONSTRAINT valid_link_recordingLink CHECK (
        recordingLink LIKE 'https://www.kaite.edu.pl/RecordingLink/%'
    ),
    CONSTRAINT valid_link_liveMeetingLink CHECK (
        liveMeetingLink LIKE 'https://www.kaite.edu.pl/MeetingLink/%'
    ),
    CONSTRAINT OnlineSyncMeetings_Meeting FOREIGN KEY (meetingID) REFERENCES Meetings (meetingID),
    CONSTRAINT OnlineSyncMeetings_pk PRIMARY KEY (meetingID)
);
```
# Tabela OnlineAsyncMeetings 
Tabela **OnlineAsyncMeetings** przechowuje informacje o asynchronicznych spotkaniach online:
- **meetingID** - id spotkania (klucz główny, klucz obcy do Meetings, int)
- recordingLink - link do nagrania spotkania (varchar(400))
    - warunek: link musi być URl-em zaczynającym się od https://www.kaite.edu.pl/RecordingLink/
```sql
CREATE TABLE OnlineAsyncMeetings (
    meetingID int NOT NULL,
    recordingLink varchar(400) NOT NULL,
    CONSTRAINT valid_recording_link CHECK (
        recordingLink LIKE 'https://www.kaite.edu.pl/RecordingLink/%'
    ),
    CONSTRAINT OnlineAsyncMeetings_Meeting FOREIGN KEY (meetingID) REFERENCES Meetings (meetingID),
    CONSTRAINT OnlineAsyncMeetings_pk PRIMARY KEY (meetingID)
);
```
# Tabela Location 
Tabela **Location** przechowuje informacje o możliwych lokalizacjach spotkań:
- **locationID** - id lokalizacji (klucz główny, int)
- location - nazwa lokalizacji lub adres (varchar(20))

```sql
CREATE TABLE Location (
    locationID int NOT NULL,
    locationName varchar(20) NOT NULL,
    CONSTRAINT Location_pk PRIMARY KEY (locationID)
);
```
# Tabela StationaryMeetings 
Tabela **StationaryMeetings** przechowuje informacje o stacjonarnych spotkaniach:
- **meetingID** - id spotkania (klucz główny, klucz obcy do Meetings, int)
- locationID - id lokalizacji (klucz obcy do Location, int)
- capacity - pojemność sali lub liczba dostępnych miejsc (int)
    - wartość domyślna: 25
    - warunek: wartość większa od 0

```sql
CREATE TABLE StationaryMeetings (
    meetingID int NOT NULL,
    locationID int NOT NULL,
    capacity int NOT NULL DEFAULT 25,
    CONSTRAINT capacity_positive CHECK (
        capacity > 0
    ),
    CONSTRAINT StationaryMeetings_Meeting FOREIGN KEY (meetingID) REFERENCES Meetings (meetingID),
    CONSTRAINT StationaryMeetings_Location FOREIGN KEY (locationID) REFERENCES Location (locationID),
    CONSTRAINT StationaryMeetings_pk PRIMARY KEY (meetingID)
);
```