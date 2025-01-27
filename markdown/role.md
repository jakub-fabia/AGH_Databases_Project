# Role

## Dyrektor

```sql
CREATE ROLE Director;
GRANT SELECT ON Employees TO Director;
GRANT SELECT ON Roles TO Director;
GRANT SELECT ON OrderDetails TO Director;
GRANT SELECT ON Attendence TO Director;
GRANT EXECUTE ON PROCEDURE AddCourse TO Dyrektor;
GRANT EXECUTE ON PROCEDURE AddCourseModule TO Dyrektor;
GRANT EXECUTE ON PROCEDURE AddCourseModuleMeeting TO Dyrektor;
GRANT EXECUTE ON PROCEDURE AddEmployee TO Dyrektor;
GRANT EXECUTE ON PROCEDURE AddMeetingWithDetails TO Dyrektor;
GRANT EXECUTE ON PROCEDURE AddStudent TO Dyrektor;
GRANT EXECUTE ON PROCEDURE AddStudy TO Dyrektor;
GRANT EXECUTE ON PROCEDURE AddTranslator TO Dyrektor;
```

## System

```sql
CREATE ROLE System;
GRANT CONTROL ON DATABASE::[YourDatabaseName] TO System;
GRANT EXECUTE ON PROCEDURE AddOrder TO System;
GRANT EXECUTE ON PROCEDURE AddOrderDetails TO System;
```

## Planista

```sql
CREATE ROLE Planner;
GRANT SELECT, INSERT, UPDATE, DELETE ON Courses TO Planner;
GRANT SELECT, INSERT, UPDATE, DELETE ON CourseModules TO Planner;
GRANT SELECT, INSERT, UPDATE, DELETE ON Meetings TO Planner;
GRANT SELECT, INSERT, UPDATE, DELETE ON TimeSchedule TO Planner;
GRANT EXECUTE ON PROCEDURE AddCourse TO Planista;
GRANT EXECUTE ON PROCEDURE AddCourseModule TO Planista;
GRANT EXECUTE ON PROCEDURE AddCourseModuleMeeting TO Planista;
GRANT EXECUTE ON PROCEDURE AddInternship TO Planista;
GRANT EXECUTE ON PROCEDURE AddMeetingWithDetails TO Planista;
GRANT EXECUTE ON PROCEDURE AddStudy TO Planista;
GRANT EXECUTE ON PROCEDURE AddSubject TO Planista;
GRANT EXECUTE ON PROCEDURE AddSubjectMeeting TO Planista;
GRANT EXECUTE ON PROCEDURE AddWebinar TO Planista;
```

## Wykładowca

```sql
CREATE ROLE Lecturer;
GRANT SELECT, INSERT, UPDATE ON Attendence TO Lecturer;
GRANT SELECT ON Courses TO Lecturer;
GRANT SELECT ON CourseModules TO Lecturer;
GRANT SELECT ON Meetings TO Lecturer;
```

## Tłumacz

```sql
CREATE ROLE Translator;
GRANT SELECT ON EmployeeLanguages TO Translator;
GRANT SELECT ON Translators TO Translator;
```

## Gość

```sql
CREATE ROLE Guest;
GRANT SELECT ON Languages TO Guest;
GRANT SELECT ON Products TO Guest;
```

## Administrator

```sql
CREATE ROLE Administrator;
GRANT CONTROL ON DATABASE::[YourDatabaseName] TO Administrator;
```

## Uczestnik

```sql
CREATE ROLE Participant;
GRANT SELECT, UPDATE ON Students TO Participant;
GRANT SELECT ON Products TO Participant;
GRANT SELECT, INSERT, DELETE ON ShoppingCart TO Participant;
GRANT SELECT, INSERT ON Orders TO Participant;
GRANT SELECT ON Certificates TO Participant;
GRANT EXECUTE ON PROCEDURE AddOrder TO Uczestnik;
GRANT EXECUTE ON PROCEDURE AddOrderDetails TO Uczestnik;
```

## Pracownik sekretariatu

```sql
CREATE ROLE SecretariatStaff;
GRANT SELECT, INSERT, UPDATE ON Students TO SecretariatStaff;
GRANT SELECT, INSERT, UPDATE ON Attendence TO SecretariatStaff;
GRANT SELECT, INSERT, DELETE ON ShoppingCart TO SecretariatStaff;
GRANT EXECUTE ON PROCEDURE AddEmployee TO Pracownik_sekretariatu;
GRANT EXECUTE ON PROCEDURE AddStudent TO Pracownik_sekretariatu;
```

## Księgowy

```sql
CREATE ROLE Accountant;
GRANT SELECT, INSERT, UPDATE ON Orders TO Accountant;
GRANT SELECT ON OrderDetails TO Accountant;
```

## Koordynator

```sql
CREATE ROLE Coordinator;
GRANT SELECT, INSERT, UPDATE, DELETE ON Subjects TO Coordinator;
GRANT SELECT, INSERT, UPDATE ON SubjectMeeting TO Coordinator;
GRANT EXECUTE ON PROCEDURE AddCourse TO Koordynator;
GRANT EXECUTE ON PROCEDURE AddCourseModule TO Koordynator;
GRANT EXECUTE ON PROCEDURE AddCourseModuleMeeting TO Koordynator;
GRANT EXECUTE ON PROCEDURE AddInternship TO Koordynator;
GRANT EXECUTE ON PROCEDURE AddMeetingWithDetails TO Koordynator;
GRANT EXECUTE ON PROCEDURE AddStudy TO Koordynator;
GRANT EXECUTE ON PROCEDURE AddSubject TO Koordynator;
GRANT EXECUTE ON PROCEDURE AddSubjectMeeting TO Koordynator;
GRANT EXECUTE ON PROCEDURE AddTranslator TO Koordynator;
GRANT EXECUTE ON PROCEDURE AddWebinar TO Koordynator;
```
