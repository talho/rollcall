namespace :db do
  namespace :migrate do
    description = "Migrate the database through scripts in vendor/plugins/rollcall/db/migrate"
    description << "and update db/schema.rb by invoking db:schema:dump."
    description << "Target specific version with VERSION=x. Turn off output with VERBOSE=false."
    desc description
    task :rollcall => :environment do
      ActiveRecord::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
      ActiveRecord::Migrator.migrate("vendor/plugins/rollcall/db/migrate/", ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
      Rake::Task["db:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby
    end
  end

  namespace :rollback do
    description = "Rollback the database through scripts in vendor/plugins/rollcall/db/migrate"
    description << "and update db/schema.rb by invoking db:schema:dump."
    desc description
    task :rollcall => :environment do
      ActiveRecord::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
      ActiveRecord::Migrator.rollback("vendor/plugins/rollcall/db/migrate/")
      Rake::Task["db:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby
    end
  end

  namespace :seed do
    description = "Add Rollcall seed data to the database"
    desc description
    task :rollcall => :environment do
      Dir.glob(File.join(File.dirname(__FILE__),'..','db','fixtures','*.rb')).each do |file|
        require file
      end
    end
  end
end

namespace :rollcall do
  namespace :generate do
    task  :data => :environment do
      rrd_path = Dir.pwd << "/rrd/"

      rrd_tool = if File.exist?(doc_yml = RAILS_ROOT+"/config/rrdtool.yml")
        YAML.load(IO.read(doc_yml))[Rails.env]["rrdtool_path"] + "/rrdtool"
      end
      current_time = Time.now

      Rollcall::SchoolDistrict.all.each do |district|
        (district.school_types.map{|school_type| school_type.gsub(/\s/,'').underscore} + district.schools.map(&:tea_id)).compact.each do |name|
          total_enrolled = (1..3).to_a[rand((1..3).to_a.length)] * 100
          (0..14).reverse_each do |i|
            total_absent = (0..20).to_a[rand((0..20).to_a.length)]
            report_date = current_time - i.days
            RRD.update("#{rrd_path}#{name}_absenteeism.rrd", [report_date.to_i.to_s,total_absent, total_enrolled], "#{rrd_tool}")
            Rollcall::SchoolDailyInfo.create(
              :school_id => Rollcall::School.find_by_tea_id(name).id,
              :total_absent => total_absent,
              :total_enrolled => total_enrolled,
              :report_date => report_date
            ) unless name.to_i == 0
          end
        end
      end
    end

    task :dailies => :environment do
      Rollcall::SchoolDistrict.all.each do |district|
        (district.schools.map).compact.each do |school|
          school_type = school.school_type.gsub(/\s/,'').underscore
          Rollcall::SchoolDailyInfo.find_all_by_school_id(school.id).each do |daily_info|
            (0..(daily_info.total_absent - 1)).each do |i|
              puts "Generating Student Dailies for #{school.display_name} on report date #{daily_info.report_date}"
              report_date = daily_info.report_date
              age_array = nil
              grade = nil
              if school_type == 'high_school'
                age_array = (15..18).to_a
                grade = (9..12).to_a[rand((9..12).to_a.length)]
              elsif school_type == 'middle_school'
                age_array = (12..14).to_a
                grade = (7..8).to_a[rand((7..8).to_a.length)]
              elsif school_type == 'elementary_school'
                age_array = (5..11).to_a
                grade = (1..6).to_a[rand((1..6).to_a.length)]
              else
                age_array = (2..4).to_a
                grade = 0
              end
              age = age_array[rand(age_array.length)]
              dob = Time.now - age.years - (rand(11) + 1).months - (rand(29) + 1).days
              bool_array = [true,false]
              sdi = Rollcall::StudentDailyInfo.create(
                :school_id => school.id,
                :report_date => report_date,
                :age => age,
                :dob => dob,
                :grade => grade,
                :gender => bool_array[rand(bool_array.length)],
                :confirmed_illness => bool_array[rand(bool_array.length)])
            end
          end
        end
      end
    end

    task :symptoms => :environment do
      Rollcall::SchoolDistrict.all.each do |district|
        (district.schools.map).compact.each do |school|
          Rollcall::SchoolDailyInfo.find_all_by_school_id(school.id).each do |daily_info|
            symptom_length = rand(Rollcall::Symptom.all.length)
            (0..symptom_length).each do |i|
              puts "Generating Reported Symptoms for #{school.display_name} on report date #{daily_info.report_date}"
              symptom_id = rand(symptom_length) + 1
              symptom = Rollcall::Symptom.find_by_id(symptom_id)
              Rollcall::StudentReportedSymptoms.create(
                :student_daily_info_id => daily_info.id,
                :symptom_id => symptom
              )  
            end
          end
        end
      end
    end

  end
end