CREATE TABLE Meetings (
    meetingID int NOT NULL IDENTITY(1,1),
    teacherID int NOT NULL,
    CONSTRAINT Meetings_Employees FOREIGN KEY (teacherID) REFERENCES Employees (employeeID),
    CONSTRAINT Meetings_pk PRIMARY KEY (meetingID)
);

CREATE TABLE Attendence (
    meetingID int NOT NULL,
    studentID int NOT NULL,
    present bit NOT NULL DEFAULT 0,
    makeUp bit NOT NULL DEFAULT 0,
    CONSTRAINT Attendence_Students FOREIGN KEY (studentID) REFERENCES Students (studentID),
    CONSTRAINT Meeting_Attendence FOREIGN KEY (meetingID) REFERENCES Meetings (meetingID),
    CONSTRAINT Attendence_pk PRIMARY KEY (meetingID,studentID)
);

CREATE TABLE TimeSchedule (
    meetingID int NOT NULL,
    startTime datetime NOT NULL,
    duration time NOT NULL DEFAULT '01:30:00',
    CONSTRAINT startTime_TimeSchedule_reasonable CHECK (
        startTime BETWEEN '2020-01-01' AND GETDATE()
    ),
    CONSTRAINT duration_TimeSchedule_reasonable CHECK (
        duration BETWEEN '00:15:00' AND '04:30:00'
    ),
    CONSTRAINT TimeSchedule_Meeting FOREIGN KEY (meetingID) REFERENCES Meetings (meetingID),
    CONSTRAINT TimeSchedule_pk PRIMARY KEY (meetingID)
);

CREATE TABLE Translators (
    meetingID int NOT NULL,
    translatorID int NOT NULL,
    languageID int NOT NULL,
    CONSTRAINT Meeting_Translators FOREIGN KEY (meetingID) REFERENCES Meetings (meetingID),
    CONSTRAINT Employees_Translators FOREIGN KEY (translatorID) REFERENCES Employees (employeeID),
    CONSTRAINT Languages_Translators FOREIGN KEY (languageID) REFERENCES Languages (languageID),
    CONSTRAINT Translators_pk PRIMARY KEY (meetingID)
);

CREATE TABLE InternshipMeetings (
    meetingID int NOT NULL,
    startDate date NOT NULL,
    CONSTRAINT startDate_InternshipMeetings_reasonable CHECK (
        startDate BETWEEN '2020-01-01' AND GETDATE()
    ),
    CONSTRAINT Meetings_InternshipMeeting FOREIGN KEY (meetingID) REFERENCES Meetings (meetingID),
    CONSTRAINT InternshipMeeting_pk PRIMARY KEY (meetingID)
);

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

CREATE TABLE OnlineAsyncMeetings (
    meetingID int NOT NULL,
    recordingLink varchar(400) NOT NULL,
    CONSTRAINT valid_recording_link CHECK (
        recordingLink LIKE 'https://www.kaite.edu.pl/RecordingLink/%'
    ),
    CONSTRAINT OnlineAsyncMeetings_Meeting FOREIGN KEY (meetingID) REFERENCES Meetings (meetingID),
    CONSTRAINT OnlineAsyncMeetings_pk PRIMARY KEY (meetingID)
);

CREATE TABLE Location (
    locationID int NOT NULL,
    locationName varchar(20) NOT NULL,
    CONSTRAINT Location_pk PRIMARY KEY (locationID)
);

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
