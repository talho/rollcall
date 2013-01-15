When /^I run an ILI report$/ do
  step %{I navigate to "Reports"}
  step %{I press "Run New Report"}
  step %{I select "Rollcall::ILIReport" from ext combo "Select Report Type"}
  step %{I press "Run Report"}
end

Then /^my ILI report should be generated$/ do
  Rollcall::ILIReport.where(user_id: current_user.id).first.should_not be_nil
end

Given /^I have reportable ILI data$/ do
  # Create schools, districts, and assign them to the current user
  springfield = Rollcall::SchoolDistrict.create(name: 'Springfield', district_id: 11111)
  southpark = Rollcall::SchoolDistrict.create(name: 'Southpark', district_id: 11112)

  Rollcall::UserSchoolDistrict.where(user_id: current_user.id, school_district_id: springfield.id).first_or_create
  Rollcall::UserSchoolDistrict.where(user_id: current_user.id, school_district_id: southpark.id).first_or_create

  sfelem = Rollcall::School.create(display_name: 'Springfield Elementary', district_id: springfield.id, school_number: 101, school_type: 'Elementary', tea_id: 111111101)
  sfmid = Rollcall::School.create(display_name: 'Springfield Middle School', district_id: springfield.id, school_number: 102, school_type: 'Elementary', tea_id: 111111102)
  sfhigh = Rollcall::School.create(display_name: 'Springfield High School', district_id: springfield.id, school_number: 001, school_type: 'Elementary', tea_id: 111111001)

  spelem = Rollcall::School.create(display_name: 'Southpark Elementary', district_id: southpark.id, school_number: 101, school_type: 'Elementary', tea_id: 111112101)
  spmid = Rollcall::School.create(display_name: 'Southpark Middle School', district_id: southpark.id, school_number: 102, school_type: 'Elementary', tea_id: 111112102)
  sphigh = Rollcall::School.create(display_name: 'Southpark High School', district_id: southpark.id, school_number: 001, school_type: 'Elementary', tea_id: 111112001)

  # create daily infos
  sfelem.school_daily_infos << Rollcall::SchoolDailyInfo.new(report_date: 1.day.ago, total_absent: 30, total_enrolled: 120)
  sfelem.school_daily_infos << Rollcall::SchoolDailyInfo.new(report_date: 2.days.ago, total_absent: 20, total_enrolled: 120)
  sfmid.school_daily_infos << Rollcall::SchoolDailyInfo.new(report_date: 1.day.ago, total_absent: 25, total_enrolled: 200)
  sfmid.school_daily_infos << Rollcall::SchoolDailyInfo.new(report_date: 2.days.ago, total_absent: 10, total_enrolled: 200)
  sfhigh.school_daily_infos << Rollcall::SchoolDailyInfo.new(report_date: 1.day.ago, total_absent: 15, total_enrolled: 300)
  sfhigh.school_daily_infos << Rollcall::SchoolDailyInfo.new(report_date: 2.days.ago, total_absent: 45, total_enrolled: 300)

  spelem.school_daily_infos << Rollcall::SchoolDailyInfo.new(report_date: 1.day.ago, total_absent: 30, total_enrolled: 150)
  spelem.school_daily_infos << Rollcall::SchoolDailyInfo.new(report_date: 2.days.ago, total_absent: 15, total_enrolled: 150)
  spmid.school_daily_infos << Rollcall::SchoolDailyInfo.new(report_date: 1.day.ago, total_absent: 25, total_enrolled: 250)
  spmid.school_daily_infos << Rollcall::SchoolDailyInfo.new(report_date: 2.days.ago, total_absent: 30, total_enrolled: 250)
  sphigh.school_daily_infos << Rollcall::SchoolDailyInfo.new(report_date: 1.day.ago, total_absent: 30, total_enrolled: 400)
  sphigh.school_daily_infos << Rollcall::SchoolDailyInfo.new(report_date: 2.days.ago, total_absent: 50, total_enrolled: 400)

  symptom = Rollcall::Symptom.where(icd9_code: "780.60", name: "Fever (Temperature)").first_or_create

  # add in some students and ili. A small number will do
  {sfelem => 4, sfmid => 2, sfhigh => 8, spelem => 1, spmid => 2, sphigh => 0}.each do |key, val|
    val.times do
      student = Rollcall::Student.create(school_id: key.id)
      sdi = Rollcall::StudentDailyInfo.create(student_id: student.id, report_date: 1.day.ago)
      sdi.symptoms << symptom
    end
  end
end

Then /^my ILI report should have the expected data$/ do
  report = Rollcall::ILIReport.where(user_id: current_user.id).first
  report.params.should eq({"totals"=>[
      {"absent"=>"170", "enrolled"=>"1420", "rate"=>"0.119718309859155", "report_date"=>2.days.ago.to_date.to_datetime.utc.to_time, "confirmed"=>nil, "ili"=>nil},
      {"absent"=>"155", "enrolled"=>"1420", "rate"=>"0.109154929577465", "report_date"=>1.day.ago.to_date.to_datetime.utc.to_time, "confirmed"=>nil, "ili"=>"17"}],
    "school_districts"=>[
      {"district"=>{"district_id"=>11112, "id"=>2, "jurisdiction_id"=>nil, "name"=>"Southpark"}, "rates"=>[
          {"absent"=>"95", "enrolled"=>"800", "rate"=>"0.11875", "report_date"=>2.days.ago.to_date.to_time.utc},
          {"absent"=>"85", "enrolled"=>"800", "rate"=>"0.10625", "report_date"=>1.day.ago.to_date.to_time.utc}], "confirmed"=>[], "ili"=>[{"report_date"=>1.day.ago.to_date.to_time.utc, "total"=>"3"}],
        "schools_with_ili"=>[
          {"confirmed"=>nil, "display_name"=>"Southpark Elementary", "ili"=>"1"},
          {"confirmed"=>nil, "display_name"=>"Southpark Middle School", "ili"=>"2"}],
        "schools_above_average"=>[]},
      {"district"=>{"district_id"=>11111, "id"=>1, "jurisdiction_id"=>nil, "name"=>"Springfield"}, "rates"=>[
          {"absent"=>"75", "enrolled"=>"620", "rate"=>"0.120967741935484", "report_date"=>2.days.ago.to_date.to_time.utc},
          {"absent"=>"70", "enrolled"=>"620", "rate"=>"0.112903225806452", "report_date"=>1.day.ago.to_date.to_time.utc}], "confirmed"=>[], "ili"=>[{"report_date"=>1.day.ago.to_date.to_time.utc, "total"=>"14"}],
        "schools_with_ili"=>[
          {"confirmed"=>nil, "display_name"=>"Springfield Elementary", "ili"=>"4"},
          {"confirmed"=>nil, "display_name"=>"Springfield High School", "ili"=>"8"},
          {"confirmed"=>nil, "display_name"=>"Springfield Middle School", "ili"=>"2"}],
        "schools_above_average"=>[]}]})
end

Then /^I my ILI report should display correctly$/ do
  visit report_path(Rollcall::ILIReport.where(user_id: current_user.id).first)
  step %{I should see "12.0% 170 1420"}
  step %{I should see "10.9% 155 17 1420"}
  step %{I should see "11.9% 95 800"}
  step %{I should see "10.6% 85 3 800"}
  step %{I should see "Southpark Elementary (0 confirmed/1 ili), Southpark Middle School (0 confirmed/2 ili)"}
  step %{I should see "12.1% 75 620"}
  step %{I should see "11.3% 70 14 620"}
  step %{I should see "Springfield Elementary (0 confirmed/4 ili), Springfield High School (0 confirmed/8 ili), Springfield Middle School (0 confirmed/2 ili)"}
end

Given /^there exists non\-reportable ILI data$/ do
  # Create schools, districts, but don't assign them to the current user
  quahog = Rollcall::SchoolDistrict.create(name: 'Quahog', district_id: 11113)

  qelem = Rollcall::School.create(display_name: 'Quahog Elementary', district_id: quahog.id, school_number: 101, school_type: 'Elementary', tea_id: 111113101)
  qmid = Rollcall::School.create(display_name: 'Quahog Middle School', district_id: quahog.id, school_number: 102, school_type: 'Elementary', tea_id: 111113102)
  qhigh = Rollcall::School.create(display_name: 'Quahog High School', district_id: quahog.id, school_number: 001, school_type: 'Elementary', tea_id: 111113001)

  qelem.school_daily_infos << Rollcall::SchoolDailyInfo.new(report_date: 1.day.ago, total_absent: 30, total_enrolled: 120)
  qmid.school_daily_infos << Rollcall::SchoolDailyInfo.new(report_date: 1.day.ago, total_absent: 20, total_enrolled: 120)
  qhigh.school_daily_infos << Rollcall::SchoolDailyInfo.new(report_date: 1.day.ago, total_absent: 25, total_enrolled: 200)

  symptom = Rollcall::Symptom.where(icd9_code: "780.60", name: "Fever (Temperature)").first_or_create

  # add in some students and ili. A small number will do
  {qelem => 4, qmid => 2, qhigh => 8}.each do |key, val|
    val.times do
      student = Rollcall::Student.create(school_id: key.id)
      sdi = Rollcall::StudentDailyInfo.create(student_id: student.id, report_date: 1.day.ago)
      sdi.symptoms << symptom
    end
  end
end
