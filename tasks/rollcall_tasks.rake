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

      class SeedRollcallData
        def self.simulate_outbreak illness, day_count, tea_id, report_date
          total_absent = 0
          day_count   += 1
          if illness == 'flu' || illness == 'pox' || illness == 'strep'
            if day_count <= 2
              total_absent = (5..10).to_a[rand((5..10).to_a.length)]
            elsif day_count >= 3 && day_count < 5
              total_absent = (11..21).to_a[rand((11..21).to_a.length)]
            elsif day_count >= 5 && day_count < 14
              total_absent = (22..45).to_a[rand((22..45).to_a.length)]
            elsif day_count >= 14 && day_count < 16
              total_absent = (15..25).to_a[rand((15..25).to_a.length)]
            elsif day_count >= 16
              day_count    = 0
              total_absent = (2..10).to_a[rand((2..10).to_a.length)]
            end
          elsif illness == 'cold'
            if day_count <= 2
              total_absent = (3..10).to_a[rand((3..8).to_a.length)]
            elsif day_count >= 3 && day_count < 6
              total_absent = (15..25).to_a[rand((10..20).to_a.length)]
            elsif day_count >= 6 && day_count < 7
              total_absent = (25..35).to_a[rand((25..35).to_a.length)]
            elsif day_count >= 7
              day_count    = 0
              total_absent = (5..10).to_a[rand((5..10).to_a.length)]
            end
          elsif illness == 'event'
            if day_count == 1
              total_absent = (20..50).to_a[rand((20..50).to_a.length)]
            else
              day_count    = 0
              total_absent = (5..10).to_a[rand((5..10).to_a.length)]
            end
          else
            if day_count == 1
              day_count    = 0
              total_absent = (0..20).to_a[rand((0..20).to_a.length)]
            end
          end
          puts "Generating #{illness} outbreak on day #{day_count}, report date #{report_date}, for school #{tea_id}"
          return [total_absent,day_count]
        end

        def self.do_student_daily_info daily_info, illness
          school_type = daily_info.school.school_type.gsub(/\s/,'').underscore
          (0..(daily_info.total_absent - 1)).each do |i|
            puts "Generating Student Dailies for #{daily_info.school.display_name} on report date #{daily_info.report_date}"
            age_array = nil
            grade     = nil
            if school_type == 'high_school'
              age_array = (15..18).to_a
              grade     = (9..12).to_a[rand((9..12).to_a.length)]
            elsif school_type == 'middle_school'
              age_array = (12..14).to_a
              grade     = (7..8).to_a[rand((7..8).to_a.length)]
            elsif school_type == 'elementary_school'
              age_array = (5..11).to_a
              grade     = (1..6).to_a[rand((1..6).to_a.length)]
            else
              age_array = (2..4).to_a
              grade     = 0
            end
            age                  = age_array[rand(age_array.length)]
            dob                  = Time.now - age.years - (rand(11) + 1).months - (rand(29) + 1).days
            gender_array         = ['M','F']
            is_confirmed_illness = false
            if illness != 'event' && illness != 'none'
              is_confirmed_illness = true
            end
            sdi        = Rollcall::StudentDailyInfo.create(
              :school_id         => daily_info.school.id,
              :report_date       => daily_info.report_date,
              :age               => age,
              :dob               => dob,
              :grade             => grade,
              :gender            => gender_array[rand(gender_array.length)],
              :confirmed_illness => is_confirmed_illness)
          end
        end

        def self.do_symptom_recording daily_info, illness
          case illness
            when 'flu' || 'pox' || 'strep'
              symptom_name = ['Sore Throat','Congestion','Influenza','Temperature','Chills','Lethargy','Headache','Cough']
            when 'cold'
              symptom_name = ['Sore Throat','Congestion','Chills','Lethargy','Headache','Cough']
            else
              symptom_name = ['None']
          end
          symptom_id = Rollcall::Symptom.find_by_name(symptom_name[rand(symptom_name.length)]).id
          puts "Generating Reported Symptoms for #{daily_info.school.display_name} on report date #{daily_info.report_date}"
          Rollcall::StudentReportedSymptoms.create(
            :student_daily_info_id => daily_info.id,
            :symptom_id            => symptom_id
          )
        end
      end

      rrd_path = Dir.pwd << "/rrd/"
      rrd_tool = if File.exist?(doc_yml = RAILS_ROOT+"/vendor/plugins/rollcall/config/rrdtool.yml")
        YAML.load(IO.read(doc_yml))[Rails.env]["rrdtool_path"] + "/rrdtool"
      else
        "rrdtool"
      end
      #Change current_time to desired test range to best suite your environment
      begin_time = Time.gm(2010,"sep",01,0,0)
      if !ARGV[1].blank?
        months_to_generate = ARGV[1].to_i.abs
        current_time       = begin_time + months_to_generate.to_i.months
      else
        y            = Time.now.year
        m            = Time.now.month
        d            = Time.now.day
        current_time = Time.gm(y, m, d)
      end
      days_to_traverse = ((current_time - begin_time) / 86400).to_i
      puts "Generating data for #{days_to_traverse} days ..."

      Rollcall::SchoolDistrict.all.each do |district|
        (district.schools.map(&:tea_id)).compact.each do |name|
          total_enrolled          = (2..6).to_a[rand((2..6).to_a.length)] * 100
          school_illness_outbreak = ['flu','pox','strep','cold','event','none']
          illness                 = school_illness_outbreak[rand(school_illness_outbreak.length)]
          sim_result              = [0, 0]
          event_counter           = 0
          (0..days_to_traverse).reverse_each do |i|
            report_date  = current_time - i.days
            sim_result   = SeedRollcallData.simulate_outbreak illness, sim_result[1], name, report_date
            total_absent = sim_result[0]
            school       = Rollcall::School.find_by_tea_id(name)
            if(i == days_to_traverse.to_i)
              RRD.update "#{rrd_path}#{name}_absenteeism.rrd",[report_date.to_i.to_s,0,total_enrolled],"#{rrd_tool}"
            end
            if report_date.strftime("%a").downcase == "sat" || report_date.strftime("%a").downcase == "sun"
              RRD.update("#{rrd_path}#{name}_absenteeism.rrd", [(report_date + 1.day).to_i.to_s,0,total_enrolled], "#{rrd_tool}")
            else
              RRD.update("#{rrd_path}#{name}_absenteeism.rrd", [(report_date + 1.day).to_i.to_s,total_absent,total_enrolled], "#{rrd_tool}")
              result = Rollcall::SchoolDailyInfo.create(
                :school_id      => school.id,
                :total_absent   => total_absent,
                :total_enrolled => total_enrolled,
                :report_date    => report_date
              ) unless name.to_i == 0
              SeedRollcallData.do_student_daily_info result,illness
              SeedRollcallData.do_symptom_recording  result,illness
            end
            if(i == 0)
              RRD.update "#{rrd_path}#{name}_absenteeism.rrd",[(report_date + 2.days).to_i.to_s,0,total_enrolled],"#{rrd_tool}"
            end
            if sim_result[1] == 0
              if illness == 'flu' || illness == 'pox' || illness == 'strep'
                school_illness_outbreak.delete(illness)
              elsif illness == 'event'
                event_counter += 1
                if event_counter == 4
                  school_illness_outbreak.delete(illness)
                end
              end
              illness = school_illness_outbreak[rand(school_illness_outbreak.length)]
            end
          end
        end
      end
      #Create School District Daily Infos
      Rollcall::SchoolDistrict.all.each do |district|
        days_to_traverse  = ((current_time - begin_time) / 86400).to_i
        (0..(days_to_traverse - 1)).reverse_each do |i|
          report_date    = current_time - i.days
          if report_date.strftime("%a").downcase != "sat" && report_date.strftime("%a").downcase != "sun"
            puts "Creating School District Daily Info for #{report_date}"
            total_absent   = Rollcall::SchoolDailyInfo.find_all_by_report_date(report_date).sum(&:total_absent)
            total_enrolled = Rollcall::SchoolDailyInfo.find_all_by_report_date(report_date).sum(&:total_enrolled)
            absentee_rate  = (total_absent.to_f / total_enrolled.to_f)
            result = Rollcall::SchoolDistrictDailyInfo.create(
              :report_date        => report_date,
              :absentee_rate      => absentee_rate,
              :total_enrollment   => total_enrolled,
              :total_absent       => total_absent,
              :school_district_id => district.id
            )
          end     
        end
      end
    end
  end
end
