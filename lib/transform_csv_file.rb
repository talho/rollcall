require 'fastercsv'
require 'import_csv_files.rb'
# Class is responsible for transforming data import files into a standard specification
#
# Example:
#   SchoolDataTransformer.new("../rollcall_data", "Houston").transform_and_import
#
class SchoolDataTransformer
  # Method initializes class instances
  #
  # Sets header names for enrollment, attendance and ili
  # Sets allowed headers if YAML file matching district name is found
  #
  # @param string dir           the dir path
  # @param string district_name the name of the district, matches folder name
  def initialize(dir, district_name)
    @dir                = File.join(dir, district_name)
    @files              = Dir.glob(File.join(@dir,"*"))
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
    @district                   = Rollcall::SchoolDistrict.find_by_name(district_name)
    unless INTERFACE_FIELDS_CONFIG.blank?
      if INTERFACE_FIELDS_CONFIG["#{district_name}"]
        if INTERFACE_FIELDS_CONFIG["#{district_name}"]["permitted_ili_field_names"]
          @allowed_ili_headers = INTERFACE_FIELDS_CONFIG["#{district_name}"]["permitted_ili_field_names"]
        end
        if INTERFACE_FIELDS_CONFIG["#{district_name}"]["permitted_enrollment_field_names"]
          @allowed_enrollment_headers = INTERFACE_FIELDS_CONFIG["#{district_name}"]["permitted_enrollment_field_names"]
        end
        if INTERFACE_FIELDS_CONFIG["#{district_name}"]["permitted_attendance_field_names"]
          @allowed_attendance_headers = INTERFACE_FIELDS_CONFIG["#{district_name}"]["permitted_attendance_field_names"]
        end
      end
    end
    Dir.ensure_exists(File.join(@dir, "archive/"))
  end

  def transform_and_import
    transform
    import
    SchoolDataImporter.new(nil).school_district_dailies(@district)
  end

  private

  # Method is responsible for ensuring the data import files are in CSV format, have the correct headers, and that
  # data is properly quoted
  #
  # Transforms School Attendance, Enrollment and ILI data into standard interface
  # Manipulates original data files, transforming them into valid csv files with headers and quoted data
  def transform
    for file_path in @files
      # The script only cares about files that do not have a unique naming convention attached to them or files
      # that have not already been transformed by a previous attempt.  Such files are treated as "new files"
      # for processing.  The process first checks to see if the file_path string has an index
      # unique to "attendance", "enrollment", and "ili".  A regex could be put in place as the variances grow.
      if file_path.downcase.index('ads').blank? && !File.directory?(file_path)
        is_transformed = false
        # Before any data transformation begins, we first set the files new name and it's headers
        if file_path.downcase.index('att')
          headers   = @attendance_headers * ","
          headers   = @allowed_attendance_headers * "," unless @allowed_attendance_headers.blank?
        elsif file_path.downcase.index('enroll')
          headers   = @enrollment_headers * ","
          headers   = @allowed_enrollment_headers * "," unless @allowed_enrollment_headers.blank?
          # Okie-dokie, I've been running into situations where the Attendance File and the Enrollment File are completely
          # out of sync, with some ISDs only giving us a snapshot of the enrollment population for the entire school year,
          # and others giving us the enrollment file with report dates that do not coincide with its Attendance
          # counterpart.  This block of code determines weather or not the enrollment file should be rebuild to
          # mirror it's Attendance counterpart.
          IO.foreach(file_path, sep_string = get_sep_string(file_path)) do |line|
            #Houstons Enrollment interface only has three fields, while all others have four.  If less than four
            #then we can assume the enrollment file does not have a report date and thus represents a snapshot of the
            #enrollment population per school.  Logically, Attendance and Enrollment should both have equal amount
            #of records, as they both should have equal amount of report dates.
            tmp_line = line.split("\t")
            tmp_line = line.split(",") if tmp_line.length <= 1
            if tmp_line.length < 4
              #Let's rebuild the enrollment file, and create a report date entry that matches up to the Attendance file.
              transform_enrollment_file
              is_transformed = true
              break
            elsif transform_enrollment_file?
              # Ok, four values doesn't exactly mean this file is copacetic.  There have been situations where the report
              # dates for the enrollment file do not match up to the attendance file.  Perhaps an oversight by the ISD,
              # we need to make sure the corresponding enrollment file delivered to us mirrors the attendance file.  We
              # can assume the dates are incorrect but that the enrollment population is a true representation of the
              # student population for that school.
              transform_enrollment_file
              is_transformed = true
              break
            end
          end
        elsif file_path.downcase.index('ili') || file_path.downcase.index('h1n1')
          headers   = @ili_headers * ","
          headers   = @allowed_ili_headers * "," unless @allowed_ili_headers.blank?
        end

        # First round of transformations begin - add headers
        file_name     = File.join(@dir, "the_temp_file.csv")
        file_to_write = File.open(file_name+".tmp", "w")
        file_to_write.puts headers
        IO.foreach(file_path, sep_string = get_sep_string(file_path)) do |line|
          if !has_headers? line
            file_to_write.puts line  
          end
        end
        file_to_write.close
        # Second round of transformations - replace tabs with commas, skip the first line since it is now headers
        file_to_write = File.open(file_name, "w")
        line_number   = 0
        IO.foreach(file_name+".tmp", sep_string = get_sep_string(file_name+".tmp")) do |line|
          if line_number != 0 && !line.blank?
            # Their might be situations where an ISD might send us tab-delimited files, with free text values that
            # might not be properly quoted which could break FasterCSV. The following code replaces all existing
            # commas with pipes and then replaces all tabs with commas. It then quotes all values, and finally
            # replaces the Pipes back with commas, leaving a csv line with properly quoted values.  It pushes the
            # values into an array and then writes out the final transformed line. Note: A regex guru could minimize the
            # amount of code needed with some rock-solid expression.
            values   = []
            new_line = line.gsub(/["][^"]*["]/) { |m| m.gsub(',','|') }
            if new_line.split("\t").length > 1
              new_line.gsub!(",","|")
            end
            new_line = new_line.gsub("\t", ",")
            new_line.split(",").each do |value|
              if !value.blank?
                value.gsub!("|",",")
                value.gsub!('"',"'") unless is_transformed
                value.strip!
                # We may have values in the data files that are double quoted already.  The above code replaces all
                # double quotes with single quotes, but this will break valid CSV detection as the code below encases
                # the entire value into double quotes.  In instances where values are already double quoted, the end
                # result is something like "'value'".  The following code strips the end and first characters of the
                # string if they are single quotes.
                if value[0].chr == "'" && value[(value.length - 1)].chr == "'"
                  value.slice!(0)
                  value.slice!((value.length - 1))
                end
                # if the value is indeed a true valid date value, we need to make sure the date value is in the
                # standard date interface format YYYY-MM-DD HH:MM:SS
                if is_date? value
                  value = "#{Time.parse(value).year}-#{Time.parse(value).month.to_s.rjust(2, '0')}-#{Time.parse(value).day.to_s.rjust(2, '0')} 00:00:00"
                end

                unless is_transformed
                  values.push('"'+value+'"')
                else
                  values.push(value)
                end
              elsif value.blank? && @district.name == "Houston" && (file_path.downcase.index('h1n1') || file_path.downcase.index('ili'))
                value.strip!
                values.push('"'+value+'"')
              end
            end
            file_to_write.puts values.join(",")
          else
            file_to_write.puts headers
          end
          line_number += 1
        end
        file_to_write.close
        File.delete(file_name+".tmp")
        File.rename(file_name, file_name+".tmp")
        # Rename the temp file back to it's original, after all transformations are complete
        File.rename(file_name+".tmp", file_path)
      end
    end
  end

  # Method is responsible for calling the import methods for each data set (Attendance, Enrollment, ILI)
  #
  # Sets file_name and renames file after import to indicate file has been processed.  Then moves file to
  # archive folder
  def import
    for file_path in @files
      if !File.directory?(file_path)
        if file_path.downcase.index('att')
          file_name = File.join(@dir, "attendance_ads_#{Time.now.year}_#{Time.now.month}_#{Time.now.day}.csv")
        elsif file_path.downcase.index('enroll')
          file_name = File.join(@dir, "enrollment_ads_#{Time.now.year}_#{Time.now.month}_#{Time.now.day}.csv")
        elsif file_path.downcase.index('ili') || file_path.downcase.index('h1n1')
          file_name = File.join(@dir, "ili_ads_#{Time.now.year}_#{Time.now.month}_#{Time.now.day}.csv")
        end
        # Third round - import data and rename the file to the new file name to indicate file has
        # been processed by the system.  If the Importer class raises an exception, the process is rescued and because
        # the file was not renamed, it will be processed again.
        #begin
          EnrollmentImporter.new(file_path).import_csv if file_path.downcase.index('enroll')
          AttendanceImporter.new(file_path).import_csv if file_path.downcase.index('att')
          IliImporter.new(file_path).import_csv if file_path.downcase.index('ili') || file_path.downcase.index('h1n1') 
          File.rename(file_path, file_name)
          FileUtils.mv(file_name, File.join(@dir, "archive"))
        #rescue
        #end
      end                   
    end
  end

  # Method is responsible for determining weather the enrollment file needs to be completely transformed
  #
  # Method checks if the report date for both attendance and enrollment match.  Returns true if report dates
  # do not match, signaling the system that the enrollment file needs to be transformed to match the attendance
  # file.
  def transform_enrollment_file?
    att_array      = []
    enr_array      = []
    att_line_array = []
    enr_line_array = []
    transform      = false
    #Load up the attendance and enrollment files into arrays
    for file_path in @files
      if !File.directory?(file_path)
        IO.foreach(file_path, sep_string = get_sep_string(file_path)) do |line|
          line.gsub!(/["][^"]*["]/) { |m| m.gsub(',','|') }
          att_array.push(line) if file_path.downcase.index('att')
          enr_array.push(line) if file_path.downcase.index('enroll')
        end
      end
    end
    # As per specifications, the first value for both the attendance file and the enrollment file should be the
    # report date.  If the dates do not match on the enrollment file, return true.
    att_line_array = att_array[0].split(",")
    att_line_array = att_array[0].split("\t") if att_line_array.blank?
    enr_line_array = enr_array[0].split(",")
    enr_line_array = enr_array[0].split("\t") if enr_line_array.blank?
    begin
      transform = Time.parse(att_line_array[0]) != Time.parse(enr_line_array[0])
    rescue
      transform = true
    end
    return transform
  end

  # Method makes sures that the enrollment file for Houston contains enrollment records for each corresponding attendance
  # date
  #
  # The method is called if the system finds that the enrollment file does not have an EnrollDate column or if
  # the report date listed on the enrollment does not match its attendance counterpart, and assumes
  # the file is a snapshot of enrollment values for all school.  The import system, however, expects the enrollment
  # file to have an EnrollDate that equates to its Attendance counterpart.  For that reason, this method reconstructs
  # the enrollment file with an EnrollDate and insures that the enrollment file mirrors the attendance file
  def transform_enrollment_file
    att_array = []
    enr_array = []
    tmp_array = []
    #Load up the attendance and enrollment files into arrays
    for file_path in @files
      if !File.directory?(file_path)
        IO.foreach(file_path, sep_string = get_sep_string(file_path)) do |line|
          line.gsub!(/["][^"]*["]/) { |m| m.gsub(',','|') }
          att_array.push(line) if file_path.downcase.index('att')
          enr_array.push(line) if file_path.downcase.index('enroll')
        end
      end
    end
    #Process enrollment file for rewrite
    @file_to_write = File.open(File.join(@dir, "tmp_enroll.tmp"),"w")
    #Run through each attendance record, when tea_id matches, use enrollment value to re-build enrollment file
    #with report dates
    att_array.each do |rec|
      date,@tmp_tea_id,school_name,absent = rec.split("\t") if rec.split("\t").length > 1
      date,@tmp_tea_id,school_name,absent = rec.split(",") if rec.split(",").length > 1
      if date.downcase.index("date").blank?
        enr_array.each do |line|
          @enrolled = 0
          tmp_line = line.split("\t")
          tmp_line = line.split(",") if tmp_line.length <= 1
          if tmp_line.length == 3
            tea_id,name,enrolled = tmp_line
          elsif tmp_line.length == 4
            enroll_date,tea_id,name,enrolled = tmp_line  
          end
          @tmp_tea_id.gsub!('"',"")
          tea_id.gsub!('"',"")
          @tmp_tea_id.gsub!("'","")
          tea_id.gsub!("'","")
          tea_id.strip!
          @tmp_tea_id.strip!
          enrolled.strip!
          enrolled.gsub!('"',"")
          enrolled.gsub!("'","")
          if tea_id.to_i != @tmp_tea_id.to_i
            next
          else
            @enrolled = enrolled.to_i
            break
          end
        end
        tmp_array.push('"'+date.gsub('"',"")+'"')
        tmp_array.push('"'+@tmp_tea_id.gsub('"',"")+'"')
        tmp_array.push('"'+school_name.gsub('"',"").gsub('|',',')+'"')
        tmp_array.push('"'+"#{@enrolled}"+'"')
        @file_to_write.puts tmp_array.join(",")
        tmp_array = []        
      end
    end
    @file_to_write.close
    for file_path in @files
      if file_path.downcase.index('enroll')
        #Delete file just read
        File.delete(file_path)
        #Rename temp file to previously read file
        File.rename(File.join(@dir, "tmp_enroll.tmp"), file_path)
      end
    end
  end

  # Method validates date format
  #
  # Method takes in a value and attempts to mach it against a series of regular expressions that represent different
  # formats for writing out a date value.  Returns true if any pattern is a match.
  def is_date? value
    is_date     = false
    reg_ex_list = [
      /^[0-9]{1,2}\/[0-9]{1,2}\/[0-9]{2,4}$/,
      /^[0-9]{1,2}-[0-9]{1,2}-[0-9]{2,4}$/,
      /^[0-9]{1,2}-[0-9]{1,2}-[0-9]{2,4}$/,
      /^[0-9]{2,4}\/[0-9]{1,2}\/[0-9]{1,2}$/,
      /^[0-9]{2,4}-[0-9]{1,2}-[0-9]{1,2}$/,
      /^[0-9]{2,4}-[0-9]{1,2}-[0-9]{1,2}$/,
      /^[0-9]{2,4}-[0-9]{1,2}-[0-9]{1,2} (\d{2}):(\d{2}):(\d{2})$/,
      /^[0-9]{1,2}-[0-9]{1,2}-[0-9]{2,4} (\d{2}):(\d{2}):(\d{2})$/,
      /^[0-9]{1,2}-[0-9]{1,2}-[0-9]{2,4}T(\d{2}):(\d{2}):(\d{2})$/,
      /^[0-9]{2,4}-[0-9]{1,2}-[0-9]{1,2}T(\d{2}):(\d{2}):(\d{2})$/,
      /^\d{6}$/,
      /^\d{8}$/
    ]
    reg_ex_list.each do |regex|
      if regex.match value
        tmp_time = nil
        # A match, but might not be a valid date value
        # first round of elimination, if the value is out of range, it's not a valid date
        begin
          tmp_time = Time.parse(value)
        rescue
          break
        end
        # Ok, value not out of range, so we need to exclude values that are greater than the
        # current date, as the system will never be processing report dates beyond today's date,
        # and values that are beyond a 5 year difference from today's date are also treated as
        # invalid date values.  Only values within a 5 year difference from today's date are accepted as
        # true valid date values.
        time_year_diff = Time.now.year - tmp_time.year
        if time_year_diff >= 0 && time_year_diff <= 5
          is_date = true
          break
        end
      end
    end
    is_date
  end

  def get_sep_string file_path
    sep_string = "\r"
    IO.foreach(file_path, sep_string) do |line|
      if line.split("\n").length > line.split("\r").length
        sep_string = "\n"
        break
      end
    end
    return sep_string
  end

  def has_headers? line
    if line.downcase.index('campusid')
      return true
    else
      return false
    end
  end
end