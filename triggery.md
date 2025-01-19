# Triggery

## Zmień dostępność produktu, jeśli jest już po jego rozpoczęciu - Jakub Fabia

```sql
CREATE TRIGGER trg_MakeProductUnavailable
ON [dbo].Products
AFTER INSERT, UPDATE
AS
BEGIN
    UPDATE Products
    SET isAvailable = 0
    WHERE productId IN (SELECT productID FROM ProductBeginningDate WHERE minStartTime <= CAST(GETDATE() AS DATE));
END;
go
```
## Automatyczne dodawanie studenta do listy obecności kursów i ich modułów po jego zakupieniu -  Mariusz Krause
```sql
CREATE TRIGGER trg_AddStudentToCourse
    ON [dbo].OrderDetails
    AFTER INSERT
    AS
BEGIN
    IF EXISTS (
        SELECT inserted.orderID
        FROM inserted
                 INNER JOIN Products p ON p.productID=inserted.productID
                 INNER JOIN Courses c ON p.productID = c.productID
                 INNER JOIN CourseModules cm ON cm.courseID=c.courseID
                 INNER JOIN CourseModuleMeeting cms ON cms.moduleID=cm.moduleID
                 INNER JOIN Meetings m ON m.meetingID=cms.meetingID
                 INNER JOIN Attendence a ON a.meetingID=m.meetingID
        WHERE EXISTS(
            SELECT *
            FROM inserted
                     INNER JOIN Orders o ON inserted.orderID=o.orderID
            WHERE a.studentID=o.studentID

        )
    )BEGIN
        RAISERROR('Student o podanym ID jest już zapisany na kurs.', 16, 1);
    END
    INSERT INTO Attendence (meetingID, studentID, present,makeUp)
    SELECT m.meetingID,o.StudentID,0,0
    FROM inserted
             INNER JOIN Orders o ON inserted.orderID=o.orderID
             INNER JOIN Products p ON p.productID=inserted.productID
             INNER JOIN Courses c ON p.productID = c.productID
             INNER JOIN CourseModules cm ON cm.courseID=c.courseID
             INNER JOIN CourseModuleMeeting cms ON cms.moduleID=cm.moduleID
             INNER JOIN Meetings m ON m.meetingID=cms.meetingID
end
```
## Automatyczne dodawanie studenta do listy obecnosci webinaru po jego zakupie - Jakub Fabia
```sql
CREATE TRIGGER trg_AddStudentToWebinar
ON [dbo].OrderDetails
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted
                 INNER JOIN Products p ON p.productID=inserted.productID
                 INNER JOIN Webinars web ON p.productID = web.productID
                 INNER JOIN Meetings m ON m.meetingID=web.meetingID
                 INNER JOIN Attendence a ON a.meetingID=m.meetingID
        WHERE EXISTS(
            SELECT *
            FROM inserted
                     INNER JOIN Orders o ON inserted.orderID=o.orderID
            WHERE a.studentID=o.studentID

        )
    )BEGIN
        RAISERROR('Student o podanym ID jest już zapisany na webinar.', 16, 1);
    END

    INSERT INTO Attendence (meetingID, studentID, present,makeUp)
    SELECT m.meetingID,o.StudentID,0,0
    FROM inserted
             INNER JOIN Orders o ON inserted.orderID=o.orderID
             INNER JOIN Products p ON p.productID=inserted.productID
             INNER JOIN Webinars web ON p.productID = web.productID
             INNER JOIN Meetings m ON m.meetingID=web.meetingID
end
```
## Automatyczne dodawanie studenta do listy obecności spotkania studyjnego po jego zakupie - Seweryn Tasior
```sql
CREATE TRIGGER trg_AddStudentToStudy
    ON [dbo].OrderDetails
    AFTER INSERT
    AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted
                 INNER JOIN Products p ON p.productID=inserted.productID
                 INNER JOIN Studies s ON p.productID = s.productID
                 INNER JOIN Internships i ON i.studyID=s.studyID
                 INNER JOIN Meetings m ON m.meetingID=i.meetingID
                 INNER JOIN Attendence a ON a.meetingID=m.meetingID
        WHERE EXISTS(
            SELECT *
            FROM inserted
                     INNER JOIN Orders o ON inserted.orderID=o.orderID
            WHERE a.studentID=o.studentID

        )
        UNION
        SELECT 1
        FROM inserted
                 INNER JOIN Products p ON p.productID=inserted.productID
                 INNER JOIN Studies s ON p.productID = s.productID
                 INNER JOIN Subjects ss ON ss.studyID=s.studyID
                 INNER JOIN SubjectMeeting sm ON sm.subjectID=ss.subjectID
                 INNER JOIN Meetings m ON m.meetingID=sm.meetingID
                 INNER JOIN Attendence a ON a.meetingID=m.meetingID
        WHERE EXISTS(
            SELECT *
            FROM inserted
                     INNER JOIN Orders o ON inserted.orderID=o.orderID
            WHERE a.studentID=o.studentID

        )
    )BEGIN
        RAISERROR('Student o podanym ID jest już zapisany na studium.', 16, 1);
    END
    INSERT INTO Attendence (meetingID, studentID, present,makeUp)
    SELECT m.meetingID,o.StudentID,0,0
    FROM inserted
             INNER JOIN Orders o ON inserted.orderID=o.orderID
             INNER JOIN Products p ON p.productID=inserted.productID
             INNER JOIN Studies s ON p.productID = s.productID
             INNER JOIN Internships i ON i.studyID=s.studyID
             INNER JOIN Meetings m ON m.meetingID=i.meetingID
    UNION
    SELECT m.meetingID,o.StudentID,0,0
    FROM inserted
             INNER JOIN Orders o ON inserted.orderID=o.orderID
             INNER JOIN Products p ON p.productID=inserted.productID
             INNER JOIN Studies s ON p.productID = s.productID
             INNER JOIN Subjects ss ON ss.studyID=s.studyID
             INNER JOIN SubjectMeeting sm ON sm.subjectID=ss.subjectID
             INNER JOIN Meetings m ON m.meetingID=sm.meetingID
end
```
