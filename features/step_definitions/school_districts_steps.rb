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