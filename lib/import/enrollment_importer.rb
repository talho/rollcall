require 'school_data_importer'
# Class is derived from SchoolDataImporter, imports enrollment data, defines MAPPING and process_record
class EnrollmentImporter < SchoolDataImporter
  EnrollmentImporter::MAPPING = [
    { :field_name => "EnrollDate",        :name => :report_date, :format => /^\d{4}-(?:0\d|1[012])-(?:0\d|1\d|2\d|3[01]) (\d{2}):(\d{2}):(\d{2})$/ },
    { :field_name => "CampusID",          :name => :school_id, :action => :tea_id2school_id, :format => /^\d+$/ },
    { :field_name => "SchoolName",        :name => :campus_name, :action => :ignoreCsvField },
    { :field_name => "CurrentEnrollment", :name => :total_enrolled, :format => /^\d+$/ }
  ]

  # Method processes record into SchoolDailyInfo
  #
  # @params rec   array  an array of records to process
  # @params attrs hash   an attribute hash{:key => value}
  def process_record(rec, attrs)
    if attrs[:school_id]
      puts "Importing Enrollment Data for School ID: #{attrs[:school_id]}"
      daily_info            = Rollcall::SchoolDailyInfo.find_by_school_id_and_report_date(attrs[:school_id], attrs[:report_date])
      daily_info            = Rollcall::SchoolDailyInfo.new if !daily_info
      daily_info.attributes = attrs
      daily_info.save
    end
  end
end