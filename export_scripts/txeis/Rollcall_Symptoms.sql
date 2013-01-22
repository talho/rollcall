/******************* Symptom data***************************/
declare @school_year varchar(4)

select @school_year = max(sch_yr)
from DR_CURRICULUM_CYR

SELECT  CID         = convert(integer,c.log_date)+convert(integer,substring(c.dt_time_stamp,13,2))+convert(integer,substring(c.dt_time_stamp,16,2))+convert(integer,substring(c.dt_time_stamp,19,2))+convert(integer,substring(c.dt_time_stamp,22,3)),
        HealthYear  = a.sch_yr,
        CampusID    = b.dist_id || b.campus_id ,
        Campus_Name = ltrim(rtrim(b.campus_name)) ,
        OrigDate    = DATEFORMAT( c.log_date, 'MM-dd-YYYY' ),
        Temperature =  c.temp ,
        Symptoms    = ltrim(rtrim(c.complaint || ' ' || c.comments)),
        Zip         = a.addr_zip ,
        Grade       = a.grd_lvl ,
        Gender      = h.SEX,
        Race        = if h.race_white = '1' then
			 if (h.race_white = '1' and h.ETHN_HISPANIC = '1' ) then 4
			 else 5
			 endif
		      else if h.race_black = '1'  then 3
			   else if h.race_asian = '1' then 2
                                else if h.race_amer_indian = '1' then 1
                                     else 6
                                     endif
                                endif
                           endif
                      endif
FROM SR_STU_ENROLL a
JOIN cr_demo b ON a.sch_yr = b.sch_yr AND a.campus_id = b.campus_id
JOIN sr_nurse_daily_log c ON a.stu_id = c.stu_id AND a.campus_id = c.campus
JOIN sr_stu_demo h ON a.sch_yr = h.sch_yr AND a.stu_id = h.stu_id
WHERE a.dt_entry = (Select max(g.dt_entry) from sr_stu_enroll g where a.stu_id = g.stu_id and g.sch_yr= @school_year)
  AND c.log_date > DATEFORMAT(DATEADD(day, -7, NOW()), 'YYYYMMDD')
  AND a.sch_yr = @school_year
ORDER BY OrigDate ;
OUTPUT TO 'C:\RollCall\Data\symptoms.csv' format ASCII ;
