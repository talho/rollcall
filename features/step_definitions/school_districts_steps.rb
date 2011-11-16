Given /^(.*) has the following school districts:$/ do |jurisdiction, table|
  rrd_path = File.join(Rails.root, "/rrd/")
  table.raw.each do |row|
    result = Rollcall::SchoolDistrict.create(
      :district_id  => row[1],
      :name         => row[0],
      :jurisdiction => Jurisdiction.find_by_name!(jurisdiction)
    )
    File.delete("#{rrd_path}district_#{result.district_id}_c_absenteeism.rrd") if File.exist?("#{rrd_path}district_#{result.district_id}_c_absenteeism.rrd")
    rrd_file = Rollcall::Rrd.find_by_file_name_and_record_id("district_#{result.district_id}_c_absenteeism.rrd", result.id)
    rrd_file.destroy unless rrd_file.blank?
    if Date.today.day < 5
      current_time = Time.gm(Date.today.year, Date.today.month, Date.today.day,0,0).at_beginning_of_month - 1.week
    else
      current_time = Time.gm(Date.today.year, Date.today.month, Date.today.day,0,0).at_beginning_of_month
    end
    Rollcall::Rrd.build_rrd("district_#{result.district_id}_c", result.id, current_time)
  end
end

Given /^the following symptoms exist[s]?:$/ do |table|  
  table.hashes.each do |row|
    Rollcall::Symptom.create(
      :icd9_code => row["icd9_code"],
      :name      => row["name"].strip
    )
  end
end

Given /^"([^\"]*)" has the following current district absenteeism data:$/ do |isd, table|
  table.hashes.each do |row|
    date = Date.today - row["day"].to_i.days
    Rollcall::SchoolDistrictDailyInfo.create(
      :report_date        => date,
      :absentee_rate      => (row['total_absent'].to_f / row['total_enrolled'].to_f),
      :total_enrollment   => row['total_enrolled'],
      :total_absent       => row['total_absent'],
      :school_district_id => Rollcall::SchoolDistrict.find_by_name!(isd).id
    )
  end
end