require 'school_data_importer'
# Class is derived from SchoolDataImporter, imports attendance data, defines MAPPING and process_record
class AttendanceImporter < SchoolDataImporter
  AttendanceImporter::MAPPING = [
    { :field_name => "AbsenceDate", :name => :report_date, :format => /^\d{4}-(?:0\d|1[012])-(?:0\d|1\d|2\d|3[01]) (\d{2}):(\d{2}):(\d{2})$/ },
    { :field_name => "CampusID",    :name => :school_id, :action => :tea_id2school_id, :format => /^\d+$/ },
    { :field_name => "SchoolName",  :name => :campus_name, :action => :ignoreCsvField },
    { :field_name => "Absent",      :name => :total_absent, :format => /^\d+$/ }
  ]

  # Method processes record into SchoolDailyInfo and runs updates on their corresponding RRDs
  #
  # @params rec   array  an array of records to process
  # @params attrs hash   an attribute hash{:key => value}
  def process_record(rec, attrs)
    puts "Importing Attendance Data for School ID: #{attrs[:school_id]}"
    @schools.push attrs[:school_id] unless attrs[:school_id].blank?
    daily_info            = Rollcall::SchoolDailyInfo.find_by_school_id_and_report_date(attrs[:school_id].to_i, attrs[:report_date])
    daily_info            = Rollcall::SchoolDailyInfo.new if !daily_info
    daily_info.attributes = attrs
    daily_info.save
  end

  # Method processes the SchoolDailyInfo and writes out the RRDs
  #
  def write_rrd_file
    @end_date     = nil
    @end_enrolled = 0
    @schools.uniq!
    Rollcall::School.find(:all, :conditions => ["id IN (?)", @schools]).each do |s|
      if ENV["RAILS_ENV"] == "cucumber" || ENV["RAILS_ENV"] == "test"
        last_update = `#{@rrd_tool} lastupdate #{@rrd_path}/#{s.tea_id}_c_absenteeism.rrd`
      else
        last_update = `#{@rrd_tool} lastupdate #{@rrd_path}/#{s.tea_id}_absenteeism.rrd`
      end
      begin
        last_update = Time.at(last_update.split("\n").last.split(':').first.to_i) + 1.day
        unless Rollcall::SchoolDailyInfo.find_by_school_id(s.id).blank?
          Rollcall::SchoolDailyInfo.find(:all,
            :conditions => ["school_id = ? AND report_date >= ?", s.id, last_update.strftime("%Y-%m-%d")],
            :order      => "report_date ASC"
          ).each {|r|
              report_time = r.report_date.to_time
              if @s_i.blank?
                @s_i = []
              end
              if r.report_date.strftime("%a").downcase == "sat" || r.report_date.strftime("%a").downcase == "sun"
                @s_i.push([(report_time + 1.day).to_i.to_s, 0, r.total_enrolled])
              else
                @s_i.push([(report_time + 1.day).to_i.to_s, r.total_absent, r.total_enrolled])
              end
            }
          begin
            puts "Importing RRD Data for #{s.display_name}"
            if ENV["RAILS_ENV"] == "cucumber" || ENV["RAILS_ENV"] == "test"
              RRD.update_batch("#{@rrd_path}/#{s.tea_id}_c_absenteeism.rrd", @s_i, "#{@rrd_tool}")
            else
              RRD.update_batch("#{@rrd_path}/#{s.tea_id}_absenteeism.rrd", @s_i, "#{@rrd_tool}")
            end
            @s_i = nil
          rescue
          end
        end
      rescue
      end
    end
  end
end