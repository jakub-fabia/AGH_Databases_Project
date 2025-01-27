BEGIN TRANSACTION

ROLLBACK

-- Dodawanie studenta

EXEC AddStudent 'Andrzej', 'Kowalsk', 'a.kowalsakaai@interia.pl',
     33, 'Warszawa', '00-781',
     'Złota', '571A', '21'

EXEC AddStudent 'Andrzej2', 'Kowalsi', 'a.kowalsaakaia@interia.pl',
     33, 'Warszawa', '00-781',
     'Złota', '571A', '21'

EXEC AddStudent 'Andrzej3', 'Kowalki', 'a.kowalsaakais@interia.pl',
     33, 'Warszawa', '00-781',
     'Złota', '571A', '21'

SELECT * FROM Students JOIN Users ON Students.userID = Users.userID WHERE studentID > 7114

-- Studia
DECLARE @studyID INT;
EXEC AddStudy 'Informatyka Data Science', 'Opis Informatyka Data Science',
     25000, 2

DECLARE @subjectID INT
EXEC AddSubject 30, 136,
                  'Algorytmy i Struktury Danych', 1,
                  'https://www.kaite.edu.pl/Syllabus/4asdasdadw324-1238yg'

EXEC AddSubjectMeeting 788, 98, 'Algorytmy dynamiczne', 'Opis',
    57, 'Stationary', 204, '2026-03-24 14:00:00', '2:00:00',
    NULL, NULL, 101

EXEC AddSubjectMeeting 787, 98, 'Algorytmy dynamiczne', 'Opis',
    57, 'OnlineSync', 204, '2026-03-28 14:00:00', '2:00:00',
    NULL, NULL

EXEC AddSubjectMeeting 787, 98, 'Algorytmy dynamiczne', 'Opis',
    57, 'OnlineAsync', 204, '2026-04-08 14:00:00', '2:00:00',
    NULL, NULL, 101

EXEC AddSubject 25, 136,
                  'Bazy Danych', 2,
                  'https://www.kaite.edu.pl/Syllabus/4asdaasdasdasdadw324-1238yg'

EXEC AddSubjectMeeting 784, 98, 'SQL', 'Opis',
    57, 'Stationary', 204, '2026-03-23 14:00:00', '2:00:00',
    NULL, NULL, 100

EXEC AddSubjectMeeting 784, 98, 'noSQL', 'Opis',
    57, 'OnlineAsync', 204, '2026-03-27 14:00:00', '2:00:00',
    NULL, NULL

EXEC AddSubjectMeeting 784, 98, 'mySQL', 'Opis',
    57, 'Stationary', 204, '2026-04-07 14:00:00', '2:00:00',
    NULL, NULL, 100

SELECT * FROM StructureStudies WHERE studyID = 27


-- Kurs

EXEC AddCourse 'Informatyka Data Science', 'Opis Informatyka Data Science',
     500, 145, 2

EXEC AddCourseModule 151, 'Algorytmy i Struktury Danych'

EXEC AddCourseModuleMeeting 524, 'Stationary', 232,
     '2025-03-23 14:00:00', '1:15:00', NULL, NULL,
    39

EXEC AddCourseModuleMeeting 520, 'Stationary', 232,
     '2025-03-25 14:00:00', '1:15:00', NULL, NULL,
    39

EXEC AddCourseModuleMeeting 519, 'OnlineSync', 232,
     '2025-03-26 14:00:00', '1:15:00', NULL, NULL

EXEC AddCourseModule 145, 'Bazy Danych'

EXEC AddCourseModuleMeeting 517, 'Stationary', 232,
     '2025-04-23 14:00:00', '1:15:00', NULL, NULL,
    39

EXEC AddCourseModuleMeeting 517, 'Stationary', 232,
     '2025-04-25 14:00:00', '1:15:00', NULL, NULL,
    39

EXEC AddCourseModuleMeeting 517, 'OnlineAsync', 232,
     '2025-04-26 14:00:00', '1:15:00', NULL, NULL

SELECT * FROM StructureCourse WHERE courseID = 145

--Webinar

EXEC AddWebinar 'Podatki', 'Opis', 200, 'OnlineSync',
                  219, '2025-02-02 12:00:00', '3:00:00'

SELECT * FROM StructureWebinar WHERE webinarID = 240

SELECT Products.productID FROM Products JOIN Webinars ON Products.productID = Webinars.productID WHERE webinarID = 240
-- Zamówienia

EXEC AddOrder 7148,
     'https://www.kaite.edu.pl/paymentLink/44E06A9812-0CD8-4B7A-AD7D-813A8123A0F7', 7390, 1, 500


EXEC AddOrder 7149,
     'https://www.kaite.edu.pl/paymentLink/44E06A98-0CD8-4B7A-AD7D-813A8123A0F7',
                    7390, 1, 25000

EXEC AddOrder 7150,
     'https://www.kaite.edu.pl/paymentLink/44E06A98-0CD8-4B7A-AD7D-813A8123A0F7',
                    7390, 1, 25000

EXEC AddOrder 7138,
     'https://www.kaite.edu.pl/paymentLink/44E06A98-0CD8-4B7A-AD7D-813A8123A0F7',
                    7386, 1, 25000

SELECT * FROM FutureEventParticipants WHERE Type = 'Studia' AND TypeID = 30

EXEC AddOrderDetails 16858, 7351, 1, 200

SELECT * FROM FutureEventParticipants WHERE studentID = 7104

EXEC AddOrderDetails 16858, 7352, 1, 500

SELECT * FROM FutureEventParticipants WHERE studentID = 7103 AND type = 'Kurs'