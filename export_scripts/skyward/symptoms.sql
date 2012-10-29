DECLARE @district_number varchar(6),
	@symptoms TABLE(CID int, HealthYear varchar(4), CampusID varchar(9), OrigDate date, Temperature int, StudentID varchar(max), Grade int, Zip varchar(10), Symptoms varchar(max));

SET @district_nubmer = '';

-- Pull ILI directly from Skyward into local SQL database
insert into @symptoms(CID, HealthYear, CampusID, OrigDate, Temperature,
		      Grade)
SELECT HltOfficeVisitMst.[OFFICE-VISIT-REF-NO], StudentHealth.[school-year], HltOfficeVisitMst.[HLT-OVM-ENTITY-ID], StudentHealth.[HLT-DATE], convert(nvarchar(20),HltOfficeVisitMst.[HLT-OVM-TEMPERATURE]),
       dbo.Student_Grade(Entity.[SCHOOL-YEAR], Student.[GRAD-YR])
FROM   StudentHealth 
JOIN   HltOfficeVisitMst ON StudentHealth.[REF-NO] = HltOfficeVisitMst.[REF-NO] AND StudentHealth.[STUDENT-ID] = HltOfficeVisitMst.[STUDENT-ID] 
JOIN   HltOfficeVisitDtl ON HltOfficeVisitMst.[OFFICE-VISIT-REF-NO] = HltOfficeVisitDtl.[OFFICE-VISIT-REF-NO]
JOIN   Student ON StudentHealth.[STUDENT-ID] = Student.[STUDENT-ID]
JOIN   Entity ON HltOfficeVisitMst.[HLT-OVM-ENTITY-ID] = Entity.[ENTITY-ID]
WHERE  (StudentHealth.[SYS-HLT-TYPE-ID] = 'HOV') AND (HltOfficeVisitDtl.[OFFICE-VISIT-DTL-TYPE] = 'V') AND
         (HltOfficeVisitDtl.[OFFICE-VISIT-DTL-ID] = 'SA' OR
          HltOfficeVisitDtl.[OFFICE-VISIT-DTL-ID] = 'NAU' OR
          HltOfficeVisitDtl.[OFFICE-VISIT-DTL-ID] = 'THR' OR
          HltOfficeVisitDtl.[OFFICE-VISIT-DTL-ID] = 'ILI' OR
          HltOfficeVisitDtl.[OFFICE-VISIT-DTL-ID] = 'HA' OR
          HltOfficeVisitDtl.[OFFICE-VISIT-DTL-ID] = 'CO' OR
          HltOfficeVisitDtl.[OFFICE-VISIT-DTL-ID] = 'CHI' OR
          HltOfficeVisitDtl.[OFFICE-VISIT-DTL-ID] = 'FEV')
  AND  StudentHealth.[HLT-DATE] > DATEADD(dd,DATEDIFF(dd,0,GETDATE()),-7) AND StudentHealth.[HLT-DATE] <= GETDATE()
GROUP BY HltOfficeVisitMst.[OFFICE-VISIT-REF-NO], StudentHealth.[school-year];
 
-- Update Zip -- This could be joined in, but I'm not confident that Name and Address would be uniq to students (ie could cause multiple rows to be specified in the join)
UPDATE @symptoms 
SET [Zip] = Address.[ZIP-CODE]
FROM HltOfficeVisitMst 
JOIN Student ON HltOfficeVisitMst.[STUDENT-ID] = Student.[STUDENT-ID] 
JOIN Name ON Student.[NAME-ID] = Name.[NAME-ID] 
JOIN Address ON Name.[ADDRESS-ID] = Address.[ADDRESS-ID]
WHERE CID = HltOfficeVisitMst.[OFFICE-VISIT-REF-NO];

-- Update Symptoms
UPDATE @symptoms 
SET [Symptoms] = stuff((SELECT ', ' + HltOfficeVisitReason.[VISIT-REASON-SDESC]
			    FROM   HltOfficeVisitMst 
			    INNER JOIN HltOfficeVisitDtl ON HltOfficeVisitMst.[OFFICE-VISIT-REF-NO] = HltOfficeVisitDtl.[OFFICE-VISIT-REF-NO] 
			    INNER JOIN HltOfficeVisitReason ON HltOfficeVisitDtl.[OFFICE-VISIT-DTL-ID] = HltOfficeVisitReason.[VISIT-REASON-ID]
			    WHERE CID = HltOfficeVisitMst.[OFFICE-VISIT-REF-NO] AND HltOfficeVisitDtl.[OFFICE-VISIT-DTL-TYPE] = 'V' FOR XML path(''), elements),1,2,'');

-- Select out for the CSV
SELECT *
FROM @symptoms;
