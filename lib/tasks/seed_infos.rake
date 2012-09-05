require 'rdoc/task' 

namespace :rollcall do
  description = "Seeds the info tables" 
  desc description
  task :seed => [
    'rollcall:school_info', 
    'rollcall:student_info',  
    'rollcall:school_district_info'   
  ]
  
  desc description
  task :school_info => :environment do
    p "Warning this is going to take a loooooonnngg time"
    Rollcall::School.all.each do |school|
      start = DateTime.now - 1.year
      start.upto(DateTime.now) do |report_date|
        total_absent = rand(100)
        total_enrolled = 1 + total_absent + rand(500)
        Rollcall::SchoolDailyInfo.create(
          :school_id => school.id, 
          :total_absent => total_absent, 
          :total_enrolled => total_enrolled,
          :report_date => report_date
        )
        p "School: #{school.display_name} Report Date: #{report_date} Absent: #{total_absent} Enrolled: #{total_enrolled}"        
      end      
    end
  end
  
  desc description
  task :student_info => :environment do
    if Rollcall::Student.all.length == 0
      Rollcall::School.all.each do |school|
        (1..25).each do |i|
          age = rand(18)
          Rollcall::Student.create(
            :first_name => "Hi",
            :last_name => "there",
            :gender => rand(1) ? "M" : "F",
            :school_id => school.id,
            :dob => age.to_i.year.ago
          )
          p "Student  SchoolId: #{school.id} DOB: #{age.to_i.year.ago}"
        end
      end
    end
    
    number_of_symptoms = Rollcall::Symptom.all.count
    
    Rollcall::Student.all.each do |student|
      p "Student id: #{student.id}"
      start = DateTime.now - 1.year
      start.upto(DateTime.now) do |report_date|
        p "DATE: #{report_date}"
        odds = rand(100)
        if (odds.to_i < 3)
          info = Rollcall::StudentDailyInfo.new
          info.student_id = student.id
          info.report_date = report_date
          info.grade = 1 + rand(12)
          
          confirmed = rand(1)
          if confirmed
            info.confirmed_illness = 1            
          end
          
          info.save
          if confirmed
            info.student_reported_symptoms.create(
              :symptom_id => rand(number_of_symptoms)              
            )
          end
          p "Info: #{info.id} Grade: #{info.grade} Report Date: #{report_date}"
        end
      end  
    end
  end
  
  desc description
  task :school_district_info => :environment do
    Rollcall::SchoolDistrict.all.each do |school_district|
      start = DateTime.now - 1.year
      start.upto(DateTime.now) do |report_date|
        total_absent = rand(100)
        total_enrolled = 1 + total_absent + rand(500)
        Rollcall::SchoolDistrictDailyInfo.create(
          :school_district_id => school_district.id, 
          :total_absent => total_absent, 
          :total_enrollment => total_enrolled,
          :report_date => report_date,
          :absentee_rate => total_absent.to_f / total_enrolled.to_f
        )
        p "Report Date: #{report_date} Absent: #{total_absent} Enrolled #{total_enrolled}"
      end  
    end
  end
end