require 'rdoc/task' 

namespace :rollcall do
  description = "Seeds the info tables" 
  desc description
  task :seed => [
    'rollcall:school_info', 
    'rollcall:student_info'
  ]
  
  desc description
  task :school_info => :environment do
    p "Warning this is going to take a loooooonnngg time"
    Rollcall::School.all.each do |school|
      ActiveRecord::Base.connection.execute("DELETE FROM rollcall_school_daily_infos WHERE school_id = #{school.id}")
      start = DateTime.now - 3.months
      total_enrolled = 100 + rand(800)
      prev = 0
      start.upto(DateTime.now) do |report_date|
        prev = total_absent = ([total_enrolled * 0.05, prev].max + (rand(2) > 0 ? -1 : 1)*rand(6)).floor
        Rollcall::SchoolDailyInfo.create(
          :school_id => school.id, 
          :total_absent => total_absent, 
          :total_enrolled => total_enrolled,
          :report_date => report_date
        )      
      end      
      p "School: #{school.display_name} Enrolled: #{total_enrolled}"  
    end
  end
  
  desc description
  task :student_info => :environment do
    p "destroying sdi"
    ActiveRecord::Base.connection.execute("DELETE FROM rollcall_student_daily_infos")
    p "destroying students"
    ActiveRecord::Base.connection.execute("DELETE FROM rollcall_students")
    
    Rollcall::School.order(:display_name).all.each do |school|
      p "#{school.display_name}"
      (1..25).each do |i|
        age = rand(18)
        Rollcall::Student.create(
          :first_name => "Unknown",
          :last_name => "Unknown",
          :gender => rand(1) ? "M" : "F",
          :school_id => school.id,
          :dob => age.to_i.year.ago
        )
      end
    end
    
    number_of_symptoms = Rollcall::Symptom.count
    
    Rollcall::Student.all.each do |student|
      p "Student id: #{student.id}"
      start = DateTime.now - 3.months
      start.upto(DateTime.now) do |report_date|
        odds = rand(100)
        if (odds.to_i < 2)
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
        end
      end  
    end
  end
end