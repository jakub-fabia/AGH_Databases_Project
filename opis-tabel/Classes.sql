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

CREATE TABLE CourseModules (
    moduleID int NOT NULL IDENTITY(1,1),
    courseID int NOT NULL,
    name varchar(50) NOT NULL,
    CONSTRAINT CourseModules_Courses FOREIGN KEY (courseID) REFERENCES Courses (courseID),
    CONSTRAINT CourseModules_pk PRIMARY KEY (moduleID)
);

CREATE TABLE CourseModuleMeeting (
    meetingID int NOT NULL,
    moduleID int NOT NULL,
    CONSTRAINT CourseModuleMeeting_CourseModules FOREIGN KEY (moduleID) REFERENCES CourseModules (moduleID),
    CONSTRAINT CourseModuleMeeting_Meeting FOREIGN KEY (meetingID) REFERENCES Meetings (meetingID),
    CONSTRAINT CourseModuleMeeting_pk PRIMARY KEY (meetingID)
);

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

CREATE TABLE SubjectMeeting (
    meetingID int NOT NULL,
    subjectID int NOT NULL,
    productID int NOT NULL,
    capacity int NOT NULL DEFAULT 20,
    CONSTRAINT SubjectMeeting_Meetings FOREIGN KEY (meetingID) REFERENCES Meetings (meetingID),
    CONSTRAINT StudyMeetings_Subjects FOREIGN KEY (subjectID) REFERENCES Subjects (subjectID),
    CONSTRAINT Products_StudyMeetings FOREIGN KEY (productID) REFERENCES Products (productID),
    CONSTRAINT SubjectMeeting_pk PRIMARY KEY (meetingID)
);

CREATE TABLE Internships (
    internshipID int NOT NULL IDENTITY(1,1),
    studyID int NOT NULL,
    meetingID int NOT NULL,
    CONSTRAINT Internships_Studies FOREIGN KEY (studyID) REFERENCES Studies (studyID),
    CONSTRAINT Internships_Meetings FOREIGN KEY (meetingID) REFERENCES Meetings (meetingID),
    CONSTRAINT Internships_pk PRIMARY KEY (internshipID)
);

CREATE TABLE Webinars (
    webinarID int NOT NULL IDENTITY(1,1),
    productID int NOT NULL,
    meetingID int NOT NULL,
    CONSTRAINT Webinars_Meeting FOREIGN KEY (meetingID) REFERENCES Meetings (meetingID),
    CONSTRAINT Webinars_Products FOREIGN KEY (productID) REFERENCES Products (productID),
    CONSTRAINT Webinars_pk PRIMARY KEY (webinarID)
);
