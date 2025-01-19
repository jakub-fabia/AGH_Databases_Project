## Tabela Courses

```sql
CREATE INDEX idx_Employees_Courses ON Courses(coordinatorID);
CREATE INDEX idx_Products_Courses ON Courses(productID);
```

## Tabela Certificates

```sql
CREATE INDEX idx_Products_Certificates ON Certificates(productID);
CREATE INDEX idx_Students_Certificates ON Certificates(studentID);
```

## Tabela EmployeeLanguages

```sql
CREATE INDEX idx_Employees_EmployeeLanguages ON EmployeeLanguages(employeeID);
CREATE INDEX idx_Languages_EmployeeLanguages ON EmployeeLanguages(languageID);
```

## Tabela EmployeeRole

```sql
CREATE INDEX idx_Roles_EmployeeRole ON EmployeeRole(roleID);
CREATE INDEX idx_Employees_EmployeeRole ON EmployeeRole(employeeID);
```

## Tabela Subjects

```sql
CREATE INDEX idx_Studies_Subjects ON Subjects(studyID);
CREATE INDEX idx_Employees_Subjects ON Subjects(subjectCoordinatorID);
```

## Tabela SubjectMeeting

```sql
CREATE INDEX idx_Meetings_SubjectMeeting ON SubjectMeeting(meetingID);
CREATE INDEX idx_Subjects_SubjectMeeting ON SubjectMeeting(subjectID);
CREATE INDEX idx_Products_SubjectMeeting ON SubjectMeeting(productID);
```

## Tabela Attendence

```sql
CREATE INDEX idx_Meetings_Attendence ON Attendence(meetingID);
CREATE INDEX idx_Students_Attendence ON Attendence(studentID);
```

## Tabela Translators

```sql
CREATE INDEX idx_Meetings_Translators ON Translators(meetingID);
CREATE INDEX idx_Employees_Translators ON Translators(translatorID);
CREATE INDEX idx_Languages_Translators ON Translators(languageID);
```

## Tabela TimeSchedule

```sql
CREATE INDEX idx_Meetings_TimeSchedule ON TimeSchedule(meetingID);
```

## Tabela Orders

```sql
CREATE INDEX idx_Students_Orders ON Orders(studentID);
```

## Tabela OrderDetails

```sql
CREATE INDEX idx_Orders_OrderDetails ON OrderDetails(orderID);
CREATE INDEX idx_Products_OrderDetails ON OrderDetails(productID);
CREATE INDEX idx_OrderStatus_OrderDetails ON OrderDetails(statusID);
```

## Tabela ShoppingCart

```sql
CREATE INDEX idx_Students_ShoppingCart ON ShoppingCart(studentID);
CREATE INDEX idx_Products_ShoppingCart ON ShoppingCart(productID);
```

## Tabela Internships

```sql
CREATE INDEX idx_Studies_Internships ON Internships(studyID);
CREATE INDEX idx_Meetings_Internships ON Internships(meetingID);
```

## Tabela InternshipMeetings

```sql
CREATE INDEX idx_Meetings_InternshipMeetings ON InternshipMeetings(meetingID);
```

## Tabela Webinars

```sql
CREATE INDEX idx_Products_Webinars ON Webinars(productID);
CREATE INDEX idx_Meetings_Webinars ON Webinars(meetingID);
```

## Tabela StationaryMeetings

```sql
CREATE INDEX idx_Meetings_StationaryMeetings ON StationaryMeetings(meetingID);
CREATE INDEX idx_Location_StationaryMeetings ON StationaryMeetings(locationID);
```

## Tabela OnlineSyncMeetings

```sql
CREATE INDEX idx_Meetings_OnlineSyncMeetings ON OnlineSyncMeetings(meetingID);
```

## Tabela OnlineAsyncMeetings

```sql
CREATE INDEX idx_Meetings_OnlineAsyncMeetings ON OnlineAsyncMeetings(meetingID);
```

## Tabela Students

```sql
CREATE INDEX idx_Users_Students ON Students(userID);
CREATE INDEX idx_Countries_Students ON Students(countryID);
```

## Tabela Employees

```sql
CREATE INDEX idx_Users_Employees ON Employees(userID);
```

## Tabela Studies

```sql
CREATE INDEX idx_Products_Studies ON Studies(productID);
```

## Tabela Meetings

```sql
CREATE INDEX idx_Employees_Meetings ON Meetings(teacherID);
```

## Tabela CourseModules

```sql
CREATE INDEX idx_Courses_CourseModules ON CourseModules(courseID);
```

## Tabela CourseModuleMeeting

```sql
CREATE INDEX idx_Meetings_CourseModuleMeeting ON CourseModuleMeeting(meetingID);
CREATE INDEX idx_CourseModules_CourseModuleMeeting ON CourseModuleMeeting(moduleID);
```
