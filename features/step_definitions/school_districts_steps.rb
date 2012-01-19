Given /^(.*) has the following school districts:$/ do |jurisdiction, table|
  table.raw.each do |row|
    result = Rollcall::SchoolDistrict.create(
      :district_id  => row[1],
      :name         => row[0],
      :jurisdiction => Jurisdiction.find_by_name!(jurisdiction)
    )
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