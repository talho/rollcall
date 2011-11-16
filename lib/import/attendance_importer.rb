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
      unless Rollcall::SchoolDailyInfo.find_by_school_id(s.id).blank?
        Rollcall::SchoolDailyInfo.find(:all,
          :conditions => ["school_id = ? AND created_at > ?", s.id, Time.now.strftime("%Y-%m-%d")],
          :order      => "report_date ASC"
        ).each {|r|
            report_time = r.report_date.to_time
            if @s_i.blank?
              #if !@new_rrd.blank?
              #  @s_i = [ [report_time.to_i.to_s, 0, recs[0].total_enrolled] ]
              #else
                @s_i = []
              #end
            end
            if r.report_date.strftime("%a").downcase == "sat" || r.report_date.strftime("%a").downcase == "sun"
              @s_i.push([(report_time + 1.day).to_i.to_s, 0, r.total_enrolled])
            else
              @s_i.push([(report_time + 1.day).to_i.to_s, r.total_absent, r.total_enrolled])
            end
            #@end_time     = report_time
            #@end_enrolled = r.total_enrolled
          }
        begin
          #@s_i.push([(@end_time + 2.days).to_i.to_s, 0, @end_enrolled])
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
    end
  end
end