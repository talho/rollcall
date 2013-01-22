/************Variables*************************/
declare @school_year varchar(4)

select @school_year = max(sch_yr)
from DR_CURRICULUM_CYR


/************Attendance************************/
SELECT
  AbsenceDate         = DATEFORMAT(calendar.day_date, 'MM-dd-YYYY' ),
  CampusID            = campus.dist_id || campus.campus_id,
  SchoolName          = campus.campus_name,
  Enrolled	      = count(enroll.stu_id),
  Absent              = count(attendance.abs_type)

FROM sr_stu_enroll enroll
JOIN cr_demo campus ON enroll.campus_id = campus.campus_id AND enroll.sch_yr = campus.sch_yr
JOIN cr_att_cal calendar ON enroll.campus_id = calendar.campus_id AND enroll.sch_yr = calendar.sch_yr AND enroll.att_trk = calendar.track
LEFT JOIN sr_att_post attendance ON enroll.stu_id = attendance.stu_id AND enroll.campus_id = attendance.campus_id AND calendar.day_date = attendance.abs_date

WHERE enroll.active_cd = '1'
  AND enroll.status_cd < '4'
  AND enroll.dt_entry = (Select max(g.dt_entry) from sr_stu_enroll g where enroll.stu_id = g.stu_id and g.sch_yr= @school_year and  enroll.campus_id = g.campus_id)
  AND enroll.sch_yr = @school_year
  AND calendar.day_date <= GETDATE()
  AND calendar.day_date > DATEADD(day, -7, NOW())
  AND calendar.membership_code in ('0','1','4','7')
  AND (attendance.abs_per IS NULL OR attendance.abs_per = (select h.att_ada_post_per from cr_att_opt h where h.sch_yr = @school_year and h.campus_id = enroll.campus_id and h.track = enroll.att_trk) )
  AND (attendance.abs_type IS NULL OR attendance.abs_type in (select post_cd from st_att_post where ada_abs = '1' and sch_yr = @school_year ) )

GROUP BY campus.dist_id, campus.campus_id, campus.campus_name, calendar.day_date
ORDER BY campus.campus_id, calendar.day_date ;
OUTPUT TO 'C:\rollcall\attendance.csv'   format ASCII ;
