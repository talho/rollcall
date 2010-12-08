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

      SchoolDistrict.all.each do |district|
        (district.school_types.map{|school_type| school_type.gsub(/\s/,'').underscore} + district.schools.map(&:school_number)).compact.each do |name|
          total_enrolled = (2..5).to_a[rand((2..5).to_a.length - 1)] * 100
          (0..29).reverse_each do |i|
            total_absent = (20..150).to_a[rand((20..150).to_a.length - 1)]
            report_date = current_time - i.days
            RRD.update("#{rrd_path}#{name}_absenteeism.rrd", [report_date.to_i.to_s,total_absent, total_enrolled], "#{rrd_tool}")
          end
        end
      end
    end
  end
end