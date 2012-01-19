require 'school_data_importer'
# Class is derived from SchoolDataImporter, imports attendance data, defines MAPPING and process_record
class AttendanceImporter < SchoolDataImporter
  AttendanceImporter::MAPPING = [
    { :field_name => "AbsenceDate", :name => :report_date, :format => /^\d{4}-(?:0\d|1[012])-(?:0\d|1\d|2\d|3[01]) (\d{2}):(\d{2}):(\d{2})$/ },
    { :field_name => "CampusID",    :name => :school_id, :action => :tea_id2school_id, :format => /^\d+$/ },
    { :field_name => "SchoolName",  :name => :campus_name, :action => :ignoreCsvField },
    { :field_name => "Absent",      :name => :total_absent, :format => /^\d+$/ }
  ]

  # Method processes record into SchoolDailyInfo
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
end