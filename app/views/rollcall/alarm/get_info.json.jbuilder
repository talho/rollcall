json.info [{
  :total_absent => @school_info.total_absent,
  :total_enrolled => @school_info.total_enrolled,
  :total_confirmed_absent => @confirmed_absents,
  :alarm_severity => @severity,
  :school_name => @school_info.school.display_name,
  :school_type => @school_info.school.school_type,
  :students => {:student_info => @student_info.as_json}
}]