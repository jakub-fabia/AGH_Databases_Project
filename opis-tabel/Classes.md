# Kategoria Classes

## Tabela Courses
Tabela **Courses** przechowuje informacje o kursach:
- **courseID** - id kursu (klucz główny, int)
    - autoinkrementacja: od wartości 1 , kolejna wartość większa o 1
- productID - id produktu (klucz obcy do Products, int)
- coordinatorID - id koordynatora kursu (klucz obcy do Employees, int)
- capacity - ilość miejsc w kursie (int, nullable)
    - warunek: capacity większe od 0

```sql
CREATE TABLE Courses (
    courseID int NOT NULL IDENTITY(1,1),
    productID int NOT NULL,
    coordinatorID int NOT NULL,
    capacity int,
    CONSTRAINT Courses_capacity_positive CHECK (
        capacity > 0
    ),
    CONSTRAINT Courses_Products FOREIGN KEY (productID) REFERENCES Products (productID),
    CONSTRAINT Employees_Courses FOREIGN KEY (coordinatorID) REFERENCES Employees (employeeID),
    CONSTRAINT Courses_pk PRIMARY KEY (courseID)
);
```

## Tabela CourseModules
Tabela **CourseModules** przechowuje informacje o modułach kursów:
- **moduleID** - id modułu kursu (klucz główny, int)
    - autoinkrementacja: od wartości 1 , kolejna wartość większa o 1
- courseID - id kursu (klucz obcy do Courses, int)
- name - nazwa modułu kursu (varchar(50))

```sql
CREATE TABLE CourseModules (
    moduleID int NOT NULL IDENTITY(1,1),
    courseID int NOT NULL,
    name varchar(50) NOT NULL,
    CONSTRAINT CourseModules_Courses FOREIGN KEY (courseID) REFERENCES Courses (courseID),
    CONSTRAINT CourseModules_pk PRIMARY KEY (moduleID)
);
```

## Tabela CourseModuleMeeting
Tabela **CourseModuleMeeting** jest tabelą pomocniczą służącą do reprezentowania relacji jeden-do-wiele pomiędzy tabelami **Meetings** i **CourseModules** :
- **meetingID** - id spotkania (klucz główny, klucz obcy do Meetings, int)
- **moduleID** - id modułu kursu (klucz obcy do CourseModules, int)

```sql
CREATE TABLE CourseModuleMeeting (
    meetingID int NOT NULL,
    moduleID int NOT NULL,
    CONSTRAINT CourseModuleMeeting_CourseModules FOREIGN KEY (moduleID) REFERENCES CourseModules (moduleID),
    CONSTRAINT CourseModuleMeeting_Meeting FOREIGN KEY (meetingID) REFERENCES Meetings (meetingID),
    CONSTRAINT CourseModuleMeeting_pk PRIMARY KEY (meetingID)
);
```

## Tabela Studies
Tabela **Studies** przechowuje informacje o programach studiów:
- **studyID** - id studiów (klucz główny, int)
    - autoinkrementacja: od wartości 1 , kolejna wartość większa o 1
- productID - id produktu (klucz obcy do Products, int)
- capacity - liczba dostępnych miejsc (int)
    - warunek: wartość wieksza od 0

```sql
CREATE TABLE Studies (
    studyID int NOT NULL IDENTITY(1,1),
    productID int NOT NULL,
    capacity int NOT NULL DEFAULT 20,
    CONSTRAINT studies_capacity_positive CHECK (
        capacity > 0
    ),
    CONSTRAINT Studies_Products FOREIGN KEY (productID) REFERENCES Products (productID),
    CONSTRAINT Studies_pk PRIMARY KEY (studyID)
);
```

## Tabela Subjects
Tabela **Subjects** przechowuje informacje o przedmiotach na studiach:
- **subjectID** - id przedmiotu (klucz główny, int)
    - autoinkrementacja: od wartości 1 , kolejna wartość większa o 1
- studyID - id studiów (klucz obcy do Studies, int)
- subjectCoordinatorID - id koordynatora przedmiotu (klucz obcy - do Employees, int)
- subjectName - nazwa przedmiotu (varchar(50))
- syllabusLink - link do sylabusa (varchar(100))
    - warunek: link musi być URl-em zaczynającym się od https://www.kaite.edu.pl/Syllabus/
- semester - numer semestru (int)
    - warunek: między 1 a 7

```sql
CREATE TABLE Subjects (
    subjectID int NOT NULL IDENTITY(1,1),
    studyID int NOT NULL,
    subjectCoordinatorID int NOT NULL,
    subjectName varchar(50) NOT NULL,
    syllabusLink varchar(400) NOT NULL,
    semester int NOT NULL,
    CONSTRAINT valid_semester CHECK (
        semester BETWEEN 1 AND 7
    ),
    CONSTRAINT valid_link_syllabusLink CHECK (
        syllabusLink LIKE 'https://www.kaite.edu.pl/Syllabus/%'
    ),
    CONSTRAINT Subjects_Studies FOREIGN KEY (studyID) REFERENCES Studies (studyID),
    CONSTRAINT Employees_Subjects FOREIGN KEY (subjectCoordinatorID) REFERENCES Employees (employeeID),
    CONSTRAINT Subjects_pk PRIMARY KEY (subjectID)
);
```

## Tabela SubjectMeeting
Tabela **SubjectMeeting** jest tabelą pomocniczą służącą do reprezentowania relacji wiele-do-wiele pomiędzy tabelami **Meetings** i **Subjects**. Pozwala ona także na zakup pojedynczego spotkania dzięki powiązaniu z tabelą **Products**:
- **meetingID** - id spotkania (klucz główny, klucz obcy do Meetings, int)
- subjectID - id przedmiotu (klucz obcy do Subjects, int)
- productID - id produktu (klucz obcy do Products, int)
- capacity - ilość miejsc na przedmiocie (int)
    - warunek: ilość miejsc większa od 0

```sql
CREATE TABLE SubjectMeeting (
    meetingID int NOT NULL,
    subjectID int NOT NULL,
    productID int NOT NULL,
    capacity int NOT NULL DEFAULT 20,
    CONSTRAINT SubjectMeeting_capacity_positive CHECK (
        capacity > 0
    ),
    CONSTRAINT SubjectMeeting_Meetings FOREIGN KEY (meetingID) REFERENCES Meetings (meetingID),
    CONSTRAINT StudyMeetings_Subjects FOREIGN KEY (subjectID) REFERENCES Subjects (subjectID),
    CONSTRAINT Products_StudyMeetings FOREIGN KEY (productID) REFERENCES Products (productID),
    CONSTRAINT SubjectMeeting_pk PRIMARY KEY (meetingID)
);
```

## Tabela Internships
Tabela **Internships** przechowuje informacje o stażach:
- **internshipID** - id stażu (klucz główny, int)
    - autoinkrementacja: od wartości 1 , kolejna wartość większa o 1
- studyID - id studiów (klucz obcy do Studies, int)
- meeting - id studiów (klucz obcy do Meetings, int)
```sql
CREATE TABLE Internships (
    internshipID int NOT NULL IDENTITY(1,1),
    studyID int NOT NULL,
    meetingID int NOT NULL,
    CONSTRAINT Internships_Studies FOREIGN KEY (studyID) REFERENCES Studies (studyID),
    CONSTRAINT Internships_Meetings FOREIGN KEY (meetingID) REFERENCES Meetings (meetingID),
    CONSTRAINT Internships_pk PRIMARY KEY (internshipID)
);
```

## Tabela Webinars
Tabela **Webinars** przechowuje informacje o webinarach:
- **webinarID** - id webinaru (klucz główny, int)
    - autoinkrementacja: od wartości 1 , kolejna wartość większa o 1
- productID - id produktu (klucz obcy do Products, int)
- meetingID - id spotkania (klucz obcy do Meetings, int)

```sql
CREATE TABLE Webinars (
    webinarID int NOT NULL IDENTITY(1,1),
    productID int NOT NULL,
    meetingID int NOT NULL,
    CONSTRAINT Webinars_Meeting FOREIGN KEY (meetingID) REFERENCES Meetings (meetingID),
    CONSTRAINT Webinars_Products FOREIGN KEY (productID) REFERENCES Products (productID),
    CONSTRAINT Webinars_pk PRIMARY KEY (webinarID)
);
```