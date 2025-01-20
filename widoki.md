# Widoki

## Frekwencja na zakończonych modułach kursów - Mariusz Krause

```sql
CREATE view dbo.AttendancePastCourseModules as
    SELECT cm.moduleID,
           cm.name                                             AS ModuleName,
           COUNT(CASE WHEN a.present = 1 THEN 1 ELSE NULL END) AS PresentCount,
           COUNT(CASE WHEN a.present = 0 THEN 1 ELSE NULL END) AS AbsentCount
    FROM CourseModules cm
             JOIN CourseModuleMeeting cms ON cms.moduleID = cm.moduleID
             JOIN Meetings m ON cms.meetingID = m.meetingID
             LEFT JOIN Attendence a ON m.meetingID = a.meetingID
    WHERE m.meetingID IN (SELECT meetingID FROM TimeSchedule WHERE startTime < GETDATE())
    GROUP BY cm.moduleID, cm.name
GO
```

## Frekwencja na zakończonych wydarzeniach - Mariusz Krause

```sql
CREATE VIEW AttendancePastEvents AS
SELECT
    m.meetingID,
    COUNT(CASE WHEN a.present = 1 THEN 1 ELSE NULL END) AS PresentCount,
    COUNT(CASE WHEN a.present = 0 THEN 1 ELSE NULL END) AS AbsentCount
FROM
    Meetings m
        LEFT JOIN Attendence a ON m.meetingID = a.meetingID
WHERE
    m.meetingID IN (SELECT meetingID FROM TimeSchedule WHERE startTime < GETDATE())
GROUP BY
    m.meetingID
GO
```

## Frekwencja na zakończonych spotkaniach studyjnych - Mariusz Krause

```sql
CREATE VIEW AttendancePastStudyMeetings AS
SELECT
    sm.meetingID,
    COUNT(CASE WHEN a.present = 1 THEN 1 ELSE NULL END) AS PresentCount,
    COUNT(CASE WHEN a.present = 0 THEN 1 ELSE NULL END) AS AbsentCount
FROM
    SubjectMeeting sm
        JOIN Meetings m ON sm.meetingID = m.meetingID
        LEFT JOIN Attendence a ON m.meetingID = a.meetingID
WHERE
    m.meetingID IN (SELECT meetingID FROM TimeSchedule WHERE startTime < GETDATE())
GROUP BY
    sm.meetingID
GO
```

## Frekwencja na zakończonych webinarach - Mariusz Krause

```sql
CREATE VIEW AttendancePastWebinars AS
SELECT
    w.webinarID,
    p.name AS WebinarName,
    COUNT(CASE WHEN a.present = 1 THEN 1 ELSE NULL END) AS PresentCount,
    COUNT(CASE WHEN a.present = 0 THEN 1 ELSE NULL END) AS AbsentCount
FROM
    Webinars w
        JOIN Meetings m ON w.meetingID = m.meetingID
        JOIN Products p ON w.productID = p.productID
        LEFT JOIN Attendence a ON m.meetingID = a.meetingID
WHERE
    m.meetingID IN (SELECT meetingID FROM TimeSchedule WHERE startTime < GETDATE())
GROUP BY
    w.webinarID, p.name
GO
```

## Frekwencja na zakończonych modułach kursów - Mariusz Krause

```sql
CREATE view dbo.AttendencePastCourseModules as
    SELECT cm.moduleID,
           cm.name                                          AS ModuleName,
           COUNT(CASE WHEN a.present = 1 THEN 1 ELSE 0 END) AS PresentCount,
           COUNT(CASE WHEN a.present = 0 THEN 1 ELSE 0 END) AS AbsentCount
    FROM CourseModules cm
             JOIN CourseModuleMeeting cms ON cm.moduleID = cms.moduleID
             JOIN Meetings m ON cms.meetingID = m.meetingID
             LEFT JOIN Attendence a ON m.meetingID = a.meetingID
    WHERE m.meetingID IN (SELECT meetingID FROM TimeSchedule WHERE startTime < GETDATE())
    GROUP BY cm.moduleID, cm.name
GO
```

## Procent obecności dla każdego spotkania - Mariusz Krause

```sql
CREATE VIEW AttendancePercentage AS
SELECT
    mt.meetingID AS 'Event ID',
    100 * SUM(CAST(at.present AS INT)) / COUNT(at.present) AS [% Frequence]
FROM
    Meetings AS mt
INNER JOIN
    Attendence AS at ON mt.meetingID = at.meetingID
INNER JOIN
    TimeSchedule AS ts ON mt.meetingID = ts.meetingID
WHERE
    ts.startTime < GETDATE()
GROUP BY
    mt.meetingID;
```

## Procent obecności na zajęciach modułu dla każdego uczestnika kursu - Mariusz Krause

```sql
CREATE VIEW AttendancePercentageCourseModule AS
SELECT
    CM.courseID,
    CM.moduleID,
    A.studentID,
    100 * SUM(CAST(A.present AS INT) + CAST(A.makeUp AS INT)) / COUNT(A.present) AS [% Frequence]
FROM
    dbo.CourseModules AS CM
    LEFT JOIN
        CourseModuleMeeting AS CMM ON CM.moduleID = CMM.moduleID
    JOIN
        dbo.Meetings AS M ON CMM.meetingID = M.meetingID
    LEFT JOIN
        dbo.Attendence AS A ON M.meetingID = A.meetingID
GROUP BY
    CM.courseID, A.studentID, CM.moduleID;
```

## Procent obecności na zajęciach dla każdego uczestnika przedmiotu - Mariusz Krause

```sql
CREATE VIEW AttendancePercentageSubject AS
SELECT
    S.studyID,
    S.subjectID,
    A.studentID,
    100 * SUM(CAST(A.present AS INT) + CAST(A.makeUp AS INT)) / COUNT(A.present) AS [% Frequence]
FROM
    Subjects AS S
    LEFT JOIN
        SubjectMeeting AS SM ON S.subjectID = SM.subjectID
    JOIN
        Meetings AS M ON SM.meetingID = M.meetingID
    LEFT JOIN
        Attendence AS A ON M.meetingID = A.meetingID
GROUP BY
    A.studentID, S.subjectID, S.studyID;
```

## Lista osób zapisanych jednocześnie na dwa i więcej kolidujące ze sobą wydarzenia - Seweryn Tasior

```sql
CREATE VIEW ConflictingRegistrations AS
SELECT
    a1.studentID,
    m1.meetingID AS Meeting1,
    m1.meetingType AS Meeting1Type,
    m2.meetingID AS Meeting2,
    m2.meetingType AS Meeting2Type,
    ts1.startTime AS Start1,
    ts1.duration AS Duration1,
    ts2.startTime AS Start2,
    ts2.duration AS Duration2
FROM
    Attendence AS a1
    JOIN
        Attendence AS a2 ON a1.studentID = a2.studentID AND a1.meetingID < a2.meetingID
    JOIN
        TimeSchedule AS ts1 ON a1.meetingID = ts1.meetingID
    JOIN
        TimeSchedule AS ts2 ON a2.meetingID = ts2.meetingID
    JOIN
        meetingType AS m1 ON ts1.meetingID = m1.meetingID
    JOIN
        meetingType AS m2 ON ts2.meetingID = m2.meetingID
WHERE
    m1.meetingType != 'OnlineAsync'
    AND m2.meetingType != 'OnlineAsync'
    AND ts1.startTime < DATEADD(MINUTE, DATEDIFF(MINUTE, '00:00:00', ts2.duration), ts2.startTime)
    AND ts2.startTime < DATEADD(MINUTE, DATEDIFF(MINUTE, '00:00:00', ts1.duration), ts1.startTime);
```

## Spis wszystkich modułów kursów z informacjami o kursie oraz ramach czasowych

```sql
CREATE VIEW CourseModulesList AS
SELECT
    cm.moduleID,
    c.courseID,
    p.name AS CourseName,
    cm.name AS ModuleName,
    ts.startTime,
    DATEADD(MINUTE, DATEDIFF(MINUTE, '00:00:00', ts.duration), ts.startTime) AS EndTime
FROM
    CourseModules AS cm
    JOIN
        Courses AS c ON cm.courseID = c.courseID
    JOIN
        Products AS p ON c.productID = p.productID
    JOIN
        CourseModuleMeeting cms ON cm.moduleID = cms.moduleID
    JOIN
        TimeSchedule AS ts ON cms.meetingID = ts.meetingID

```

## Lista dłużników - Jakub Fabia

```sql
CREATE VIEW DebtorsList AS
SELECT
    o.orderID,
    s.studentID,
    CONCAT(u.firstName, ' ', u.lastName) AS StudentName,
    od.statusID,
    od.productID,
    (SELECT MIN(pbd.minStartTime)
     FROM productBeginningDate AS pbd
     WHERE p.productID = pbd.productID) AS minStartTime
FROM
    Orders AS o
    JOIN
        Students AS s ON o.studentID = s.studentID
    JOIN
        Users AS u ON s.userID = u.userID
    JOIN
        OrderDetails AS od ON o.orderID = od.orderID
    JOIN
        Products AS p ON od.productID = p.productID
WHERE
    (SELECT MIN(pbd.minStartTime)
     FROM productBeginningDate AS pbd
     WHERE p.productID = pbd.productID) < GETDATE()
    AND od.statusID IN (4, 5, 6);
```

## Lista wszystkich przyszłych wydarzeń - Seweryn Tasior

```sql
CREATE VIEW FutureEvents AS
SELECT
    m.meetingID,
    CASE
        WHEN EXISTS (SELECT 1 FROM StationaryMeetings sm WHERE sm.meetingID = m.meetingID) THEN 'Stacjonarne'
        WHEN EXISTS (SELECT 1 FROM OnlineSyncMeetings os WHERE os.meetingID = m.meetingID) THEN 'Zdalne - Synchroniczne'
        WHEN EXISTS (SELECT 1 FROM OnlineAsyncMeetings oa WHERE oa.meetingID = m.meetingID) THEN 'Zdalne - Asynchroniczne'
        ELSE 'Nieznany typ lokalizacji'
    END AS LocationType,
    CASE
        WHEN EXISTS (SELECT 1 FROM SubjectMeeting sm WHERE sm.meetingID = m.meetingID) THEN 'Spotkanie studyjne'
        WHEN EXISTS (SELECT 1 FROM CourseModuleMeeting cmm WHERE cmm.meetingID = m.meetingID) THEN 'Moduł kursu'
        WHEN EXISTS (SELECT 1 FROM Webinars w WHERE w.meetingID = m.meetingID) THEN 'Webinar'
        ELSE 'Inne wydarzenie'
    END AS EventType,
    ts.startTime,
    COUNT(a.studentID) AS RegisteredCount
FROM Meetings m
    JOIN
        TimeSchedule ts ON m.meetingID = ts.meetingID
    LEFT JOIN
        Attendence a ON m.meetingID = a.meetingID
WHERE ts.startTime > GETDATE()
GROUP BY m.meetingID, ts.startTime;

```

## Pokazuje jakiego typu jest spotkanie - Seweryn Tasior

```sql
CREATE VIEW MeetingType AS
SELECT
    Meetings.meetingID,
    'OnlineSync' AS meetingType
FROM
    Meetings
    JOIN
        OnlineSyncMeetings ON Meetings.meetingID = OnlineSyncMeetings.meetingID
UNION
SELECT
    Meetings.meetingID,
    'Stacionary' AS meetingType
FROM
    Meetings
    JOIN
        StationaryMeetings ON Meetings.meetingID = StationaryMeetings.meetingID
UNION
SELECT
    Meetings.meetingID,
    'OnlineAsync' AS meetingType
FROM
    Meetings
    JOIN
        OnlineAsyncMeetings ON Meetings.meetingID = OnlineAsyncMeetings.meetingID;

```

## Wyświetla zamówione produkty z rozróżnieniem na typy - Seweryn Tasior

```sql
CREATE VIEW OrderedProducts AS
SELECT
    o.orderID,
    od.productID,
    'Studia' AS ProductType,
    p.name AS ProductName,
    od.pricePaid,
    o.createdAt AS OrderDate
FROM
    Studies s
    JOIN
        Products p ON s.productID = p.productID
    JOIN
        OrderDetails od ON p.productID = od.productID
    JOIN
        Orders o ON od.orderID = o.orderID
UNION
SELECT
    o.orderID,
    od.productID,
    'Kurs' AS ProductType,
    p.name AS ProductName,
    od.pricePaid,
    o.createdAt AS OrderDate
FROM
    Courses s
    JOIN
        Products p ON s.productID = p.productID
    JOIN
        OrderDetails od ON p.productID = od.productID
    JOIN
        Orders o ON od.orderID = o.orderID
UNION
SELECT
    o.orderID,
    od.productID,
    'Webinar' AS ProductType,
    p.name AS ProductName,
    od.pricePaid,
    o.createdAt AS OrderDate
FROM
    Webinars s
    JOIN
        Products p ON s.productID = p.productID
    JOIN
        OrderDetails od ON p.productID = od.productID
    JOIN
        Orders o ON od.orderID = o.orderID
UNION
SELECT
    o.orderID,
    od.productID,
    'Spotkanie Studyjne' AS ProductType,
    p.name AS ProductName,
    od.pricePaid,
    o.createdAt AS OrderDate
FROM
    SubjectMeeting s
    JOIN
        Products p ON s.productID = p.productID
    JOIN
        OrderDetails od ON p.productID = od.productID
    JOIN
        Orders o ON od.orderID = o.orderID;
```

## Lista obecności do kursów (Imiona i nazwiska uczestników) - Jakub Fabia

```sql
CREATE VIEW ParticipantListPerCourse AS
SELECT
    c.courseID,
    p.name AS courseName,
    m.meetingID,
    a.studentID,
    CONCAT(u.firstName, ' ', u.lastName) AS StudentName,
    a.present,
    a.makeUp
FROM
    Courses c
    JOIN
        Products p ON p.productID = c.productID
    JOIN
        CourseModules cm ON c.courseID = cm.courseID
    JOIN
        Meetings m ON cm.courseID = m.meetingID
    JOIN
        Attendence a ON m.meetingID = a.meetingID
    JOIN
        Students st ON a.studentID = st.studentID
    JOIN
        Users u ON st.userID = u.userID;

```

## Lista obecności do studiów (Imiona i nazwiska uczestników) - Jakub Fabia

```sql
CREATE VIEW ParticipantListPerStudy AS
SELECT
    s.studyID,
    p.name AS TrainingName,
    a.studentID,
    CONCAT(u.firstName, ' ', u.lastName) AS StudentName,
    a.present,
    a.makeUp
FROM
    Studies s
    JOIN
        Products p ON s.productID = p.productID
    JOIN
        SubjectMeeting sm ON s.studyID = sm.subjectID
    JOIN
        Meetings m ON sm.meetingID = m.meetingID
    JOIN
        Attendence a ON m.meetingID = a.meetingID
    JOIN
        Students st ON a.studentID = st.studentID
    JOIN
        Users u ON st.userID = u.userID;
```

## Lista obecności do spotkań studyjnych (Imiona i nazwiska uczestników) - Jakub Fabia

```sql
CREATE VIEW ParticipantListPerStudyMeeting AS
SELECT
    sm.meetingID,
    s.subjectID,
    s.subjectName,
    a.studentID,
    CONCAT(u.firstName, ' ', u.lastName) AS StudentName,
    a.present,
    a.makeUp
FROM
    SubjectMeeting sm
    JOIN
        Subjects s ON sm.subjectID = s.subjectID
    JOIN
        Meetings m ON sm.meetingID = m.meetingID
    JOIN
        Attendence a ON m.meetingID = a.meetingID
    JOIN
        Students st ON a.studentID = st.studentID
    JOIN
        Users u ON st.userID = u.userID;

```

## Lista obecności do webinarów (Imiona i nazwiska uczestinków) - Jakub Fabia

```sql
CREATE VIEW ParticipantListPerWebinar AS
SELECT
    w.webinarID,
    p.name AS WebinarName,
    m.meetingID,
    a.studentID,
    CONCAT(u.firstName, ' ', u.lastName) AS StudentName,
    a.present,
    a.makeUp
FROM
    Webinars w
    JOIN
        Products p ON w.productID = p.productID
    JOIN
        Meetings m ON w.meetingID = m.meetingID
    JOIN
        Attendence a ON m.meetingID = a.meetingID
    JOIN
        Students st ON a.studentID = st.studentID
    JOIN
        Users u ON st.userID = u.userID;
```

## Data i godzina rozpoczęcia pierwszego spotkania produktu - Jakub Fabia

```sql
CREATE VIEW ProductBeginningDate AS
SELECT
    S.productID,
    MIN(startTime) AS minStartTime
FROM
    Studies AS S
    LEFT JOIN
        Subjects Sb ON S.studyID = Sb.studyID
    LEFT JOIN
        SubjectMeeting SM ON Sb.subjectID = SM.subjectID
    JOIN
        Meetings M ON SM.meetingID = M.meetingID
    JOIN
        TimeSchedule TS ON M.meetingID = TS.meetingID
GROUP BY
    S.productID
UNION
SELECT
    SM.productID,
    MIN(startTime) AS minStartTime
FROM
    SubjectMeeting AS SM
    JOIN
        Meetings M ON SM.meetingID = M.meetingID
    JOIN
        TimeSchedule TS ON M.meetingID = TS.meetingID
GROUP BY
    SM.productID
UNION
SELECT
    C.productID,
    MIN(startTime) AS minStartTime
FROM
    Courses AS C
    LEFT JOIN
        CourseModules CM ON C.courseID = CM.courseID
    LEFT JOIN
        CourseModuleMeeting CMM ON CM.moduleID = CMM.moduleID
    JOIN
        Meetings M ON CMM.meetingID = M.meetingID
    JOIN
        TimeSchedule TS ON M.meetingID = TS.meetingID
GROUP BY
    C.productID
UNION
SELECT
    W.productID,
    MIN(startTime) AS minStartTime
FROM
    Webinars AS W
    JOIN
        Meetings M ON W.meetingID = M.meetingID
    JOIN
        TimeSchedule TS ON M.meetingID = TS.meetingID
GROUP BY
    W.productID;
```

## Zestawienie przychodów dla każdego kursu - Seweryn Tasior

```sql
CREATE VIEW RevenuePerCourse AS
SELECT
    c.courseID,
    p.name AS CourseName,
    SUM(od.pricePaid) AS TotalRevenue
FROM
    Courses AS c
    JOIN
        Products AS p ON c.productID = p.productID
    JOIN
        OrderDetails AS od ON p.productID = od.productID
GROUP BY
    c.courseID, p.name;
```

## Zestawienie przychodów dla każdego studium - Seweryn Tasior

```sql
CREATE VIEW RevenuePerStudy AS
SELECT
	s.studyID,
	p.name AS StudyName,
	SUM(od.pricePaid) AS TotalRevenue
FROM
	Studies s
    JOIN
        Products p ON s.productID = p.productID
    JOIN
        OrderDetails od ON p.productID = od.productID
GROUP BY
	s.studyID, p.name
```

## Zestawienie przychodów dla każdego szkolenia - Seweryn Tasior

```sql
CREATE VIEW RevenuePerStudyMeeting AS
SELECT
    sm.subjectID,
    p.name AS StudyMeetingName,
    SUM(od.pricePaid) AS TotalRevenue
FROM
    SubjectMeeting AS sm
    JOIN
        Products AS p ON sm.productID = p.productID
    JOIN
        OrderDetails AS od ON p.productID = od.productID
GROUP BY
    p.name, sm.subjectID;
```

## Zestawienie przychodów dla każdego webinaru - Seweryn Tasior

```sql
CREATE VIEW RevenuePerWebinar AS
SELECT
    w.webinarID,
    p.name AS WebinarName,
    SUM(od.pricePaid) AS TotalRevenue
FROM
    Webinars AS w
    JOIN
        Products AS p ON w.productID = p.productID
    JOIN
        OrderDetails AS od ON p.productID = od.productID
GROUP BY
    w.webinarID, p.name;
```

## Wyświetla harmonogram pokoi zarezerwowanych - Jakub Fabia

```sql
CREATE VIEW RoomSchedule AS
SELECT
    sm.meetingID,
    location,
    startTime,
    DATEADD(MINUTE, DATEDIFF(MINUTE, '00:00:00', ts.duration), ts.startTime) AS endTime
FROM
    StationaryMeetings AS sm
    LEFT JOIN
        Location AS l ON sm.locationID = l.locationID
    JOIN
        TimeSchedule AS ts ON sm.meetingID = ts.meetingID;
```

## Wyświetla listę spotkań studyjnych z ich godziną rozpoczęcia i zakończenia - Seweryn Tasior

```sql
CREATE VIEW StudyMeetingsList AS
SELECT
    sm.meetingID,
    s.studyID,
    sm.subjectID,
    p.name AS StudyName,
    ts.startTime,
    DATEADD(MINUTE, DATEDIFF(MINUTE, '00:00:00', ts.duration), ts.startTime) AS EndTime
FROM
    SubjectMeeting AS sm
    JOIN
        Subjects AS s ON sm.subjectID = s.subjectID
    JOIN
        TimeSchedule AS ts ON sm.meetingID = ts.meetingID
    JOIN
        Products AS p ON s.studyID = p.productID;
```

## Raport o liczbie osób zapisanych na przyszłe wydarzenia - Mariusz Krause

```sql
CREATE VIEW UpcomingEventsRegistration AS
SELECT
    m.meetingID,
    CASE
        WHEN EXISTS (SELECT 1 FROM SubjectMeeting sm WHERE sm.meetingID = m.meetingID) THEN 'Spotkanie studyjne'
        WHEN EXISTS (SELECT 1 FROM CourseModuleMeeting cmm WHERE cmm.meetingID = m.meetingID) THEN 'Moduł kursu'
        WHEN EXISTS (SELECT 1 FROM Webinars w WHERE w.meetingID = m.meetingID) THEN 'Webinar'
        ELSE 'Inne wydarzenie'
    END AS EventType,
    ts.startTime,
    COUNT(DISTINCT a.studentID) AS RegisteredCount
FROM
    Meetings AS m
    JOIN
        TimeSchedule AS ts ON m.meetingID = ts.meetingID
    JOIN
        Attendence AS a ON m.meetingID = a.meetingID
    JOIN
        Orders AS o ON a.studentID = o.studentID
    JOIN
        OrderDetails AS od ON o.orderID = od.orderID
WHERE
    ts.startTime > GETDATE()
    AND od.statusID IN (3, 4, 5, 6)
GROUP BY
    m.meetingID,
    ts.startTime;
```

## Struktura Webinarów - Seweryn Tasior

```sql
CREATE VIEW StructureWebinar AS
    SELECT W.webinarID, P.name as 'WebinarName', 'OnlineSync' as 'Type', startTime,
           DATEADD(SECOND, DATEDIFF(SECOND, '00:00:00', ts.duration), ts.startTime) as 'endTime', liveMeetingLink as Location, recordingLink as Recording
    FROM Webinars as W
    JOIN dbo.Products P on P.productID = W.productID
    JOIN TimeSchedule TS on TS.meetingID = W.meetingID
    JOIN OnlineSyncMeetings OM ON OM.meetingID = W.meetingID
    UNION
    SELECT W.webinarID, P.name as 'WebinarName', 'OnlineAsync' as 'Type', startTime,
           DATEADD(SECOND, DATEDIFF(SECOND, '00:00:00', ts.duration), ts.startTime) as 'endTime', NULL as Location, recordingLink as Recording
    FROM Webinars as W
    JOIN dbo.Products P on P.productID = W.productID
    JOIN TimeSchedule TS on TS.meetingID = W.meetingID
    JOIN OnlineAsyncMeetings OM ON OM.meetingID = W.meetingID
GO
```

## Sturktura Kursów - Jakub Fabia
```sql
CREATE view dbo.StructureCourse as
    SELECT C.courseID,
           P.name                                                                   as 'CourseName',
           CM.moduleID,
           CM.name                                                                  as 'ModuleName',
           'Stationary'                                                             as 'Type',
           startTime,
           DATEADD(SECOND, DATEDIFF(SECOND, '00:00:00', ts.duration), ts.startTime) as 'endTime',
           locationName                                                             as Location,
           NULL                                                                     as Recording
    FROM Courses as C
             JOIN dbo.Products P on P.productID = C.productID
             LEFT OUTER JOIN dbo.CourseModules CM on C.courseID = CM.courseID
             LEFT OUTER JOIN dbo.CourseModuleMeeting CMM on CM.moduleID = CMM.moduleID
             JOIN TimeSchedule TS on TS.meetingID = CMM.meetingID
             JOIN StationaryMeetings SM ON SM.meetingID = CMM.meetingID
             JOIN Location ON SM.locationID = Location.locationID
    UNION
    SELECT C.courseID,
           P.name                                                                   as 'CourseName',
           CM.moduleID,
           CM.name                                                                  as 'ModuleName',
           'OnlineSync'                                                             as 'Type',
           startTime,
           DATEADD(SECOND, DATEDIFF(SECOND, '00:00:00', ts.duration), ts.startTime) as 'endTime',
           liveMeetingLink                                                          as Location,
           recordingLink                                                            as Recording
    FROM Courses as C
             JOIN dbo.Products P on P.productID = C.productID
             LEFT OUTER JOIN dbo.CourseModules CM on C.courseID = CM.courseID
             LEFT OUTER JOIN dbo.CourseModuleMeeting CMM on CM.moduleID = CMM.moduleID
             JOIN TimeSchedule TS on TS.meetingID = CMM.meetingID
             JOIN OnlineSyncMeetings OM ON OM.meetingID = CMM.meetingID
    UNION
    SELECT C.courseID,
           P.name                                                                   as 'CourseName',
           CM.moduleID,
           CM.name                                                                  as 'ModuleName',
           'OnlineAsync'                                                            as 'Type',
           startTime,
           DATEADD(SECOND, DATEDIFF(SECOND, '00:00:00', ts.duration), ts.startTime) as 'endTime',
           NULL                                                                     as Location,
           recordingLink                                                            as Recording
    FROM Courses as C
             JOIN dbo.Products P on P.productID = C.productID
             LEFT OUTER JOIN dbo.CourseModules CM on C.courseID = CM.courseID
             LEFT OUTER JOIN dbo.CourseModuleMeeting CMM on CM.moduleID = CMM.moduleID
             JOIN TimeSchedule TS on TS.meetingID = CMM.meetingID
             JOIN OnlineAsyncMeetings OM ON OM.meetingID = CMM.meetingID
GO
```

## Struktura Studiów - Mariusz Krause

```sql
CREATE VIEW StructureStudies AS
    SELECT S.studyID, P.name as 'StudyName', SB.subjectID, SB.subjectName as 'SubjectName', 'Stationary' as 'Type', startTime,
            DATEADD(SECOND, DATEDIFF(SECOND, '00:00:00', ts.duration), ts.startTime) as 'endTime', locationName as Location, NULL as Recording
    FROM Studies as S
    JOIN Products P ON P.productID = S.productID
    LEFT OUTER JOIN Subjects SB ON S.studyID = SB.studyID
    LEFT OUTER JOIN SubjectMeeting SBM ON SB.subjectID = SBM.subjectID
    JOIN TimeSchedule TS ON SBM.meetingID = TS.meetingID
    JOIN StationaryMeetings SM ON SBM.meetingID = SM.meetingID
    JOIN Location L ON SM.locationID = L.locationID
    UNION
    SELECT S.studyID, P.name as 'StudyName', SB.subjectID, SB.subjectName as 'SubjectName', 'OnlineSync' as 'Type', startTime,
            DATEADD(SECOND, DATEDIFF(SECOND, '00:00:00', ts.duration), ts.startTime) as 'endTime', liveMeetingLink as Location, recordingLink as Recording
    FROM Studies as S
    JOIN Products P ON P.productID = S.productID
    LEFT OUTER JOIN Subjects SB ON S.studyID = SB.studyID
    LEFT OUTER JOIN SubjectMeeting SBM ON SB.subjectID = SBM.subjectID
    JOIN TimeSchedule TS ON SBM.meetingID = TS.meetingID
    JOIN OnlineSyncMeetings OM ON SBM.meetingID = OM.meetingID
    UNION
    SELECT S.studyID, P.name as 'StudyName', SB.subjectID, SB.subjectName as 'SubjectName', 'OnlineAsync' as 'Type', startTime,
            DATEADD(SECOND, DATEDIFF(SECOND, '00:00:00', ts.duration), ts.startTime) as 'endTime', NULL as Location, recordingLink as Recording
    FROM Studies as S
    JOIN Products P ON P.productID = S.productID
    LEFT OUTER JOIN Subjects SB ON S.studyID = SB.studyID
    LEFT OUTER JOIN SubjectMeeting SBM ON SB.subjectID = SBM.subjectID
    JOIN TimeSchedule TS ON SBM.meetingID = TS.meetingID
    JOIN OnlineAsyncMeetings OM ON SBM.meetingID = OM.meetingID
GO
```