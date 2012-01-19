Given /^"([^\"]*)" has the following schools:$/ do |isd, table|
  table.hashes.each do |row|
    @district = Rollcall::SchoolDistrict.find_by_name(isd)
    result    = Rollcall::School.create(
      :display_name  => row["name"],
      :tea_id        => row["tea_id"],
      :district_id   => @district.id,
      :school_number => row["school_number"],
      :gmap_lat      => row["gmap_lat"],
      :gmap_lng      => row["gmap_lng"],
      :gmap_addr     => row["gmap_addr"],
      :postal_code   => row["postal_code"],
      :school_type   => row["school_type"]
    )
  end
end

Given /^"([^\"]*)" has the following current school absenteeism data:$/ do |isd, table|
  school            = ''
  report_date       = ''
  total_enrolled    = ''
  district          = Rollcall::SchoolDistrict.find_by_name isd
  if Date.today.day < 5
    current_time = Time.gm(Date.today.year, Date.today.month, Date.today.day,0,0).at_beginning_of_month - 1.week
  else
    current_time = Time.gm(Date.today.year, Date.today.month, Date.today.day,0,0).at_beginning_of_month
  end
  table.hashes.each do |row|
    if school.blank?
      school    = Rollcall::School.find_by_display_name(row['school_name'])
    else
      if school.display_name != row['school_name']
        school    = Rollcall::School.find_by_display_name(row['school_name'])
      end
    end
    report_date    = current_time + row["day"].strip.to_i.days
    total_absent   = row['total_absent'].strip.to_i
    total_enrolled = row['total_enrolled'].strip.to_i
    result = Rollcall::SchoolDailyInfo.create(
      :school_id      => school.id,
      :total_absent   => total_absent,
      :total_enrolled => total_enrolled,
      :report_date    => report_date
    )
  end
end