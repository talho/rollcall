require 'rdoc/task' 

namespace :seed do
  description = "Seeds the info tables" 
  task :seed => [
    'seed:school_info', 
    'seed:student_info',  
    'seed:school_district_info'   
  ]
  
  task :school_info => :environment do
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
      end      
    end
  end
  
  task :student_info => :environment do
    if Rollcall::Student.all.length == 0
      Rollcall::School.all.each do |school|
        (1..200).each do |i|
          age = rand(18)
          Rollcall::Student.create(
            :first_name => "Hi",
            :last_name => "there",
            :gender => rand(1) ? "M" : "F",
            :school_id => school.id,
            :dob => age.to_i.year.ago
          )  
        end
      end
    end
    
    number_of_symptoms = Rollcall::Symptoms.all.count
    
    Rollcall::Student.all.each do |student|
      start = DateTime.now - 1.year
      start.upto(DateTime.now) do |report_date|
        odds = rand(100)
        if (odds < 15)
          info = Rollcall::StudentDailyInfo.new
          info.student_id = student.id
          info.report_date = report_date
          info.grade = 1 + rand(12)
          
          confirmed = rand(1)
          if confirmed
            info.confirmed_illness = 1
            info.student_reported_symptoms.create(
              :symptom_id => rand(number_of_symptoms)              
            )
          end
          
          info.save
        end
      end  
    end
  end
  
  task :school_district_info => :environment do
    Rollcall::SchoolDistrict.all.each do |school_district|
      start = DateTime.now - 1.year
      start.upto(DateTime.now) do |report_date|
        total_absent = rand(100)
        total_enrolled = 1 + total_absent + rand(500)
        Rollcall::SchoolDistrictDailyInfo.create(
          :school_district_id => school_district.id, 
          :total_absent => total_absent, 
          :total_enrolled => total_enrolled,
          :report_date => report_date,
          :absentee_rate => total_absent.to_f / total_enrollment.to_f
        )
      end  
    end
  end
end