require 'fastercsv'
require 'import_csv_files.rb'
# Class is responsible for transforming data import files into a standard specification
#
# Example:
#   SchoolDataTransformer.new("../rollcall_data/HISD").transform_and_import
#
class SchoolDataTransformer
  # Method initializes class instances
  #
  # Sets header names for enrollment, attendance and ili
  # Sets allowed headers if YAML file matching ISD is found
  #
  # @param string isd_dir the dir path 
  def initialize(isd_dir)
    @dir                = isd_dir
    @files              = Dir.glob(File.join(isd_dir, "*"))
    @enrollment_headers = [
      "EnrollDate",
      "CampusID",
      "SchoolName",
      "CurrentEnrollment"
    ]
    @attendance_headers = [
      "AbsenceDate",
      "CampusID",
      "SchoolName",
      "Absent"
    ]
    @ili_headers = [
      "CID",
      "HealthYear",
      "CampusID",
      "CampusName",
      "OrigDate",
      "DateOfOnset",
      "Temperature",
      "Symptoms",
      "Zip",
      "Grade",
      "InSchool",
      "Confirmed",
      "Released",
      "Diagnosis",
      "Treatment",
      "Name",
      "Contact",
      "Phone",
      "DOB",
      "Gender",
      "Race",
      "FollowUp",
      "Doctor",
      "DoctorAddress"
    ]
    @allowed_ili_headers        = nil
    @allowed_enrollment_headers = nil
    @allowed_attendance_headers = nil
    if File.exist?(doc_yml = RAILS_ROOT+"vendor/plugins/rollcall/config/#{isd_dir}_fields.yml")
      if YAML.load(IO.read(doc_yml))["permitted_ili_field_names"]
        @allowed_ili_headers = YAML.load(IO.read(doc_yml))["permitted_ili_field_names"]
      end
      if YAML.load(IO.read(doc_yml))["permitted_enrollment_field_names"]
        @allowed_enrollment_headers = YAML.load(IO.read(doc_yml))["permitted_enrollment_field_names"]
      end
      if YAML.load(IO.read(doc_yml))["permitted_attendance_field_names"]
        @allowed_attendance_headers = YAML.load(IO.read(doc_yml))["permitted_attendance_field_names"]
      end
    end
  end

  # Method is responsible for ensuring the data import files are in CSV format, have the correct headers, and that
  # data is properly quoted
  def transform_and_import
    for file_path in @files
      # The script only cares about files that do not have a unique naming convention attached to them.  Such files
      # are treated as "new files" for processing.  The process first checks to see if the file_path string has an index
      # unique to "attendance", "enrollment", and "ili".  A regex could be put in place as the variances grow.
      if file_path.downcase.index('ads').blank?
        # Before any data transformation begins, we first set the files new name and it's headers
        if file_path.downcase.index('att')
          file_name = File.join(@dir, "attendance_ads_#{Time.now.year}_#{Time.now.month}_#{Time.now.day}.csv")
          headers   = @attendance_headers * ","
          headers   = @allowed_attendance_headers * "," unless @allowed_attendance_headers.blank?
        elsif file_path.downcase.index('enroll')
          file_name = File.join(@dir, "enrollment_ads_#{Time.now.year}_#{Time.now.month}_#{Time.now.day}.csv")
          headers   = @enrollment_headers * ","
          headers   = @allowed_enrollment_headers * "," unless @allowed_enrollment_headers.blank?
        elsif file_path.downcase.index('ili')
          file_name = File.join(@dir, "ili_ads_#{Time.now.year}_#{Time.now.month}_#{Time.now.day}.csv")
          headers   = @ili_headers * ","
          headers   = @allowed_ili_headers * "," unless @allowed_ili_headers.blank?
        end
        # First round of transformations begin - add headers
        file         = File.open(file_path, "r+" )
        file_mem_bak = file
        file.puts headers
        file_mem_bak.each do |line|
          file.puts line
        end
        file.close
        # Second round of transformations - replace tabs with commas, skip the first line since it is now headers
        if(!open_csv(true,","))
          file         = File.open(file_path, "r+" )
          file_mem_bak = file
          line_number  = 0
          file_mem_bak.each do |line|
            if line_number != 0
              # Their might be situations where an ISD might send us tab-delimited files, with free text values that might not be
              # properly quoted which could break FasterCSV.  The following code replaces all existing commas with pipes and then
              # replaces all tabs with commas.  It then quotes all values, and finally replaces the Pipes back with commas, leaving
              # a csv line with properly quoted values.  It pushes the values into an array and then writes out the final
              # transformed line.
              values = []
              line.gsub!(",", "|")
              line.gsub!("\t", ",")
              line.split(",").each do |value|
                value.gsub!("|",",")
                value.gsub!('"',"'")
                values.push('"'+value+'"')
              end
              file.puts values.join(",")+"\r\n"
            end
            line_number += line_number + 1
          end
          file.close
        end
        # Third round of transformation - import data and rename the file to the new file name to indicate file has
        # been processed by the system.  If the Importer class raises an exception, the process is rescued and because
        # the file was not renamed, it will be processed again.
        begin
          #EnrollmentImporter.new(file_path).import_csv if file_path.downcase.index('enroll')
          #AttendanceImporter.new(file_path).import_csv if file_path.downcase.index('att')
          #IliImporter.new(file_path).import_csv if file_path.downcase.index('ili')
          File.rename(file_path, file_name)
        rescue

        end
      end
    end
  end

  # Method returns false if file is not a valid csv file
  #
  # @param boolean incl_headers open file with headers
  # @param string  col_sep      the delimiter separator
  def open_csv incl_headers, col_sep
    begin
      FasterCSV.open(@filename, :headers => incl_headers, :col_sep => col_sep)
    rescue
      return false
    end
  end
end