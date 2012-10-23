
DECLARE @district_number varchar(6), 
	@excluded_campuses TABLE(entityid char(3)),
	@attendance TABLE(id int, EnrollDate date, CampusID varchar(9), SchoolName varchar(512), Enrollment int, Absent int),
	
SET @district_nubmer = '';
--INSERT INTO @excluded_campuses(entityid)
--VALUES (0);


-- Pull Enrollment directly from Skyward into local SQL database
INSERT INTO @attendance(id, EnrollDate, CampusID, SchoolName, CurrentEnrollment)
SELECT EntityStdCnts.[ENTITY-ID], GETDATE(), (@district_number + EntityStdCnts.[ENTITY-ID]), Entity.[ENTITY-NAME], EntityStdCnts.[CURR-NON-DUP-CNT]
FROM   Entity 
INNER JOIN EntityStdCnts ON Entity.[ENTITY-ID] = EntityStdCnts.[ENTITY-ID]
WHERE  EntityStdCnts.[entity-id] NOT IN (select entityid from @excluded_campuses) 
  AND EntityStdCnts.[grad-year] = 9999
  AND  EntityStdCnts.[school-year] = Entity.[SCHOOL-YEAR];

-- Pull Attendance informaiton directly from Skyward into local SQL database
update @attendance
set    Absent = EnrollmentCounts.[Absent]
FROM   Entity 
INNER JOIN EnrollmentCounts ON Entity.[ENTITY-ID] = EnrollmentCounts.CampusID
WHERE  EntityStdCnts.[entity-id] NOT IN (select entityid from @excluded_campuses)
  AND  Entity.[ENTITY-ID] = id;

-- Select out the csv
SELECT *
FROM @attendance;





