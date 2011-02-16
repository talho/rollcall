Given /^(.*) has the following school districts:$/ do |jurisdiction, table|
  table.raw.each do |row|
    Factory(:school_district, :name => row[0], :jurisdiction => Jurisdiction.find_by_name!(jurisdiction))
  end
end

Given /^"([^\"]*)" has the following schools:$/ do |isd, table|
  table.hashes.each do |row|
    Factory(:school,
            :name => row["Name"],
            :display_name => row["DisplayName"],
            :tea_id       => row["TeaId"],
            :school_id    => row["SchoolId"],
            :school_number => row["SchoolNumber"],
            :address => row["Address"],
            :postal_code => row["Zipcode"],
            :school_type => row["SchoolType"],
            :level => row["Level"],
            :district => Rollcall::SchoolDistrict.find_by_name!(isd))
  end
end

Given /^"([^\"]*)" has the following current absenteeism data:$/ do |isd, table| 
  table.hashes.each do |row|
    date = Date.today - row["Day"].to_i.days
    Rollcall::AbsenteeReport.create!(
      :school => Rollcall::School.find_by_display_name!(row["SchoolName"]),
      :report_date => "#{date} 00:00:00",
      :enrolled => row["Enrolled"],
      :absent => row["Absent"])
  end
end
