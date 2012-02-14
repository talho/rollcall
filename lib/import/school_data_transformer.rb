require 'csv'
# Class is responsible for transforming data import files into a standard specification
#
# Example:
#   SchoolDataTransformer.new("../rollcall_data", "Houston").transform_files
#   or
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
    # Load the interface fields yaml config file
    if File.exist?(doc_yml = RAILS_ROOT+"/vendor/plugins/rollcall/config/interface_fields.yml")
      int_yml = YAML.load_file(File.join(File.dirname(__FILE__), '..', '..', 'config', 'interface_fields.yml'))
      @INTERFACE_FIELDS_CONFIG = int_yml
      @INTERFACE_FIELDS_CONFIG.freeze
    end
    unless @INTERFACE_FIELDS_CONFIG.blank?
      if @INTERFACE_FIELDS_CONFIG["#{district_name}"]
        if @INTERFACE_FIELDS_CONFIG["#{district_name}"]["permitted_ili_field_names"]
          @allowed_ili_headers = @INTERFACE_FIELDS_CONFIG["#{district_name}"]["permitted_ili_field_names"]
        end
        if @INTERFACE_FIELDS_CONFIG["#{district_name}"]["permitted_enrollment_field_names"]
          @allowed_enrollment_headers = @INTERFACE_FIELDS_CONFIG["#{district_name}"]["permitted_enrollment_field_names"]
        end
        if @INTERFACE_FIELDS_CONFIG["#{district_name}"]["permitted_attendance_field_names"]
          @allowed_attendance_headers = @INTERFACE_FIELDS_CONFIG["#{district_name}"]["permitted_attendance_field_names"]
        end
      end
    end
    Dir.ensure_exists(File.join(@dir, "archive/"))
  end

  # Method calls the transform_file and import methods, effectively preparing the data files for immediate import into
  # the system
  #
  # Perform data transformation on necessary fields
  # Imports CSV data into the system
  # Run school district dailies for the district after all data has been imported into the system
  def transform_and_import
    transform_files
    import
    if !@attendance_file.blank? && !@enroll_file.blank?
      SchoolDataImporter.new(nil).school_district_dailies(@district)
    end
  end

  # Method calls the rename, extract, reorder_files, and transform methods in order to bring delivered data files
  # into a standard interface for import into the system
  #
  # Extract files if files are in archival format (ie, 7z, zip)
  # Reorder the files into instance variables
  # Perform data transformation on necessary fields
  def transform_files
    extract
    reorder_files
    transform @attendance_file unless @attendance_file.blank?
    transform @enroll_file unless @enroll_file.blank?
    transform @ili_file unless @ili_file.blank?
  end
  
  private
  
  # Method extracts CSV files
  def extract
    for file_path in @files
      if !File.directory?(file_path)
        if file_path.downcase.index('.7zip') || file_path.downcase.index('.7z') || file_path.downcase.index('.zip')
          extension = '7zip' if file_path.downcase.index('.7zip')
          extension = '7z' if file_path.downcase.index('.7z')
          extension = 'zip' if file_path.downcase.index('.zip')
          cmd = "7za e -o#{@dir} #{file_path}"
          puts "Extracting #{file_path}: #{cmd}"
          system(cmd)
          if cmd
            if file_path.downcase.index('att')
              file_name = File.join(@dir, "attendance_ads_#{Time.now.year}_#{Time.now.month}_#{Time.now.day}.#{extension}")
            elsif file_path.downcase.index('enroll')
              file_name = File.join(@dir, "enrollment_ads_#{Time.now.year}_#{Time.now.month}_#{Time.now.day}.#{extension}")
            elsif file_path.downcase.index('ili') || file_path.downcase.index('h1n1')
              file_name = File.join(@dir, "ili_ads_#{Time.now.year}_#{Time.now.month}_#{Time.now.day}.#{extension}")
            else
              file_name = File.join(@dir, "ads_#{Time.now.year}_#{Time.now.month}_#{Time.now.day}.#{extension}")
            end
            File.rename(file_path, file_name)
            FileUtils.mv(file_name, File.join(@dir, "archive"))
          end
        end
      end
    end

  end
  # Method is responsible for ensuring the data import files are in CSV format, have the correct headers, and that
  # data is properly quoted
  #
  # Transforms School Attendance, Enrollment and ILI data into standard interface
  # Manipulates original data files, transforming them into valid csv files with headers and quoted data
  def transform file_path
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
        all_purpose_f = []
        file_to_write.puts headers
        IO.foreach(file_path, sep_string = get_sep_string(file_path)) do |line|
          unless line.blank?
            if !has_headers? line
              file_to_write.puts line
            end
          end         
        end
        file_to_write.close
        # Second round of transformations - replace tabs with commas, skip the first line since it is now headers
        file_to_write = File.open(file_name, "w")
        line_number   = 0

        IO.foreach(file_name+".tmp", sep_string = get_sep_string(file_name+".tmp")) do |line|
          if @district.name == "Socorro" && file_path.downcase.index('att') &&
                  ((Time.now.month > 7 ? Time.now.year : (Time.now.year - 1)) - Time.parse(line.split(",").first).year) >=1
          else
            if @district.name == "Socorro" && file_path.downcase.index('att') && Time.parse(line.split(",").first).month < 8
            else
              if line_number != 0 && !line.blank?
                # Their might be situations where an ISD might send us tab-delimited files, with free text values that
                # might not be properly quoted which could break CSV. The following code replaces all existing
                # commas with pipes and then replaces all tabs with commas. It then quotes all values, and finally
                # replaces the Pipes back with commas, leaving a csv line with properly quoted values.  It pushes the
                # values into an array and then writes out the final transformed line. Note: A regex guru could minimize the
                # amount of code needed with some rock-solid expression.
                values   = []
                new_line = line.gsub(/["][^"]*["]/) { |m| m.gsub(',','|') if @district.name != "Waco" }
                new_line.gsub!(/['][^']*[']/) { |m| m.gsub(',','|') if @district.name != "Waco" }
                if new_line.split("\t").length > 1
                  new_line.gsub!(",","|")
                end
                new_line = new_line.gsub("\t", ",")
                #NOTE: Following unique to Anthony files, specifically ILI
                if @district.name != "Houston" && @district.name != "Waco" && @district.name != "Midland"
                  new_line = new_line.gsub("','", '","')
                  new_line = new_line.gsub(",'",',"')
                  new_line = new_line.gsub(', ','|')
                end
                if @district.name == "Waco"
                  new_line = new_line.gsub(",",";") if file_path.downcase.index('ili')
                  new_line = new_line.gsub("|",",")
                end
                #NOTE: END
                value_pass = 1
                new_line.split(",").each do |value|
                  if !value.blank?
                    value.gsub!("|",",")
                    value.gsub!('"',"'") unless is_transformed
                    #initial strip to remove leading and trailing whitespaces, including new lines and carriage returns
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
                    #second strip in case original value was encased in single quotes
                    value.strip!
                    if file_path.downcase.index('att')
                      if (value_pass == 2 && @district.name == "Tyler") ||
                        (value_pass == 2 && @district.name == "Socorro")
                        if value.length == 2
                          value = "0#{value}"
                        elsif value.length == 1
                          value = "00#{value}"
                        end
                        value = "#{@district.district_id}#{value}"
                      end
                      if value_pass == 2 && @district.name == "Socorro"
                        if value.length < 9
                          if @district.district_id == value[0..5].to_i && value[6..value.length].length == 2
                            value = "#{@district.district_id}0#{value[6..value.length]}"
                          end
                        end
                      end
                      if (value_pass == 4 || value_pass == 5) && @district.name == "Socorro"
                        value.gsub!(",","")
                      end
                    end
                    # if the value is indeed a true valid date value, we need to make sure the date value is in the
                    # standard datetime interface format YYYY-MM-DD HH:MM:SS
                    if is_date? value
                      value = is_date? value, true
                      value = "#{Time.parse(value).year}-#{Time.parse(value).month.to_s.rjust(2, '0')}-#{Time.parse(value).day.to_s.rjust(2, '0')} 00:00:00"
                    end
                    if value_pass == 1
                      value.gsub!("|","")
                    end
                    if file_path.downcase.index('h1n1') || file_path.downcase.index('ili')
                      if value_pass == 2 && @district.name == "Socorro"
                        value = "#{Time.parse(value).year}-#{Time.parse(value).month.to_s.rjust(2, '0')}-#{Time.parse(value).day.to_s.rjust(2, '0')} 00:00:00"
                      end
                    end
                    if value_pass == 1 && (@district.name == "McKinney" || @district.name == "Ector")
                      value.gsub!("T00:", " 00:")
                    end
                    if value_pass == 3 && @district.name == "Midland" && file_path.downcase.index('ili')
                      if all_purpose_f.blank?
                        for f_p in @files
                          if f_p.downcase.index('enroll')
                            IO.foreach(f_p, sep_string = get_sep_string(f_p)) do |l|
                              all_purpose_f.push([l.split(",")[2].gsub('"', '').strip.downcase,l.split(",")[1].gsub('"','').strip])
                            end
                            all_purpose_f.uniq!
                            break
                          end
                        end
                      end
                      all_purpose_f.each{|el|
                        if el[0] == new_line.split(',')[3].gsub('"','').strip.downcase
                          value = el[1]
                          break
                        end
                      }
                    end
                    if value_pass == 6 && @district.name == "Waco" && file_path.downcase.index('ili')
                      sym = []
                      Rollcall::Symptom.all.each {|s|
                        if value.downcase.index(s.name.downcase)
                          sym.push(s.name)
                        end
                      }
                      if sym.blank?
                        value = "None"
                      else
                        value = sym.join(",")
                      end
                    end
                    if (value_pass == 8 && @district.name == "Waco" && file_path.downcase.index('ili'))
                    else
                      unless is_transformed
                        values.push('"'+value+'"')
                      else
                        values.push(value)
                      end
                    end
                  elsif value.blank? && (file_path.downcase.index('h1n1') || file_path.downcase.index('ili'))
                    value.strip!
                    values.push('"'+value+'"')
                  end
                  value_pass += 1
                end


                if @district.name == "Socorro" && file_path.downcase.index('ili')
                  @so_lines = [] if @so_lines.blank?
                  if @so_lines.length > 1 && @so_lines.last[1] == values[1]
                    @so_lines.push(values)
                    @so_lines.each{|so|
                      i = 0
                      @so_lines.length.times do
                        unless @so_lines[i+1].blank?
                          if so[2] == @so_lines[i+1][2]
                            @so_symptom_line = [] if @so_symptom_line.blank?
                            @so_symptom_line.push(so[4])
                            @so_symptom_line.uniq!
                          end
                        end
                        i += 1
                      end
                    }
                  else
                    if @so_lines.blank? || @so_lines.length == 1
                      if @so_lines.blank?
                        @so_lines.push(values)
                      else
                        if @so_lines.last[1] == values[1]
                          @so_lines.push(values)
                        else
                          file_to_write.puts @so_lines.last.join(",")
                          @so_lines = []
                          @so_lines.push(values)
                        end
                      end
                    else
                      if @so_lines.length > 1 && @so_lines.last[1] != values[1]
                        if @so_symptom_line.blank?
                          @so_lines.each{|s_o|
                            file_to_write.puts s_o.join(",")
                          }
                        else
                          symp_string = @so_symptom_line.join(",").gsub('"','')
                          file_to_write.puts [@so_lines.first[0],@so_lines.first[1],@so_lines.first[2],@so_lines.first[3],
                                              symp_string,@so_lines.first[5], @so_lines.first[6]].join(",")
                          @so_symptom_line = []
                        end
                        @so_lines = []
                        @so_lines.push(values)
                      end
                    end
                  end
                else
                  file_to_write.puts values.join(",")
                end
              elsif !line.blank?
                file_to_write.puts headers
              end
              line_number += 1
            end

          end
        end
        file_to_write.close
        File.delete(file_name+".tmp")
        File.rename(file_name, file_name+".tmp")
        # Rename the temp file back to it's original, after all transformations are complete
        File.rename(file_name+".tmp", file_path)
      end

  end

  # Method is responsible for calling the import methods for each data set (Attendance, Enrollment, ILI)
  #
  # Sets file_name and renames file after import to indicate file has been processed.  Then moves file to
  # archive folder
  def import
    att_file_name = File.join(@dir, "attendance_ads_#{Time.now.year}_#{Time.now.month}_#{Time.now.day}.csv")
    enr_file_name = File.join(@dir, "enrollment_ads_#{Time.now.year}_#{Time.now.month}_#{Time.now.day}.csv")
    ili_file_name = File.join(@dir, "ili_ads_#{Time.now.year}_#{Time.now.month}_#{Time.now.day}.csv")
    EnrollmentImporter.new(@enroll_file).import_csv unless @enroll_file.blank?
    AttendanceImporter.new(@attendance_file).import_csv unless @attendance_file.blank?
    IliImporter.new(@ili_file).import_csv unless @ili_file.blank?
    File.rename(@enroll_file, enr_file_name) unless @enroll_file.blank?
    File.rename(@attendance_file, att_file_name) unless @attendance_file.blank?
    File.rename(@ili_file, ili_file_name) unless @ili_file.blank?
    FileUtils.mv(enr_file_name, File.join(@dir, "archive")) unless @enroll_file.blank?
    FileUtils.mv(att_file_name, File.join(@dir, "archive")) unless @attendance_file.blank?
    FileUtils.mv(ili_file_name, File.join(@dir, "archive")) unless @ili_file.blank?
    if !@attendance_file.blank? && !@enroll_file.blank?
      SchoolDataImporter.new(nil).school_district_dailies(@district)
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
    puts "Transforming enrollment file for #{@district.name}"
    att_array = []
    enr_array = []
    tmp_array = []
    #Load up the attendance and enrollment files into arrays
    for file_path in @files
      if !File.directory?(file_path)
        IO.foreach(file_path, sep_string = get_sep_string(file_path)) do |line|
          unless line.blank?
            line.gsub!(/["][^"]*["]/) { |m| m.gsub(',','|') }
            att_array.push(line) if file_path.downcase.index('att')
            enr_array.push(line) if file_path.downcase.index('enroll')
          end         
        end
      end
    end
    #Process enrollment file for rewrite
    @file_to_write = File.open(File.join(@dir, "tmp_e.tmp"),"w")
    #Run through each attendance record, when tea_id matches, use enrollment value to re-build enrollment file
    #with report dates
    
    att_array.each do |rec|
      unless @allowed_attendance_headers.blank?
        if @allowed_attendance_headers.length == 3
          date,@tmp_tea_id,absent = rec.split(",")
        else
          date,@tmp_tea_id,school_name,absent = rec.split(",")
        end
      else
        date,@tmp_tea_id,school_name,absent = rec.split(",")
      end
      
      if date.downcase.index("date").blank?
        enr_array.each do |line|
          @enrolled = 0
          if @district.name == "Waco"
            tmp_line = line.split("|")
          else
            tmp_line = line.split("\t")
            tmp_line = line.split(",") if tmp_line.length <= 1
          end

          if tmp_line.length == 3
            if is_date?(tmp_line[0].gsub('"',''))
              enroll_date,tea_id,enrolled = tmp_line
            else
              tea_id,name,enrolled = tmp_line
            end           
          elsif tmp_line.length == 4
            enroll_date,tea_id,name,enrolled = tmp_line  
          end
          if @district.name == "Tyler"
            if tea_id.length == 2
              tea_id = "0#{value}"
            elsif tea_id.length == 1
              tea_id = "00#{value}"
            end
            tea_id = "#{@district.district_id}#{tea_id}"
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
          enrolled.gsub!("|","")
          if tea_id.to_i != @tmp_tea_id.to_i
            next
          else
            @enrolled = enrolled.to_i
            break
          end
        end
        tmp_array.push('"'+date.gsub('"',"")+'"')
        tmp_array.push('"'+@tmp_tea_id.gsub('"',"")+'"')
        tmp_array.push('"'+school_name.gsub('"',"").gsub('|',',')+'"') unless school_name.blank?
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
        File.rename(File.join(@dir, "tmp_e.tmp"), file_path)
      end
    end
  end

  # Method validates date format
  #
  # Method takes in a value and attempts to mach it against a series of regular expressions that represent different
  # formats for writing out a date value.  Returns true if any pattern is a match.
  def is_date?(value, return_value_flag = false)
    new_value      = ''
    original_value = value
    value          = value.split(" ").first if value.split(" ").length > 1
    value          = value.split("T").first if value.split("T").length > 1
    if value.length == 7 && value.to_i.to_s.length == 7
      value = "0#{original_value}"
    end
    reg_ex_list    = [
      [/^[0-1][0-9]{1,2}\/[0-3][0-9]{1,2}\/[0-9]{4}$/,"%m-%d-%Y"],
      [/^[0-1][0-9]{1,2}\/[0-3][0-9]{1,2}\/[0-9]{2}$/,"%m-%d-%y"],
      [/^[1-9]{1}\/[0-3][0-9]{1,2}\/[0-9]{4}$/,"%m-%d-%Y"],
      [/^[1-9]{1}\/[0-3][0-9]{1,2}\/[0-9]{2}$/,"%m-%d-%y"],

      [/^[0-3][0-9]{1,2}\/[0-1][0-9]{1,2}\/[0-9]{4}$/,"%d-%m-%Y"],
      [/^[0-3][0-9]{1,2}\/[0-1][0-9]{1,2}\/[0-9]{2}$/,"%d-%m-%y"],
      [/^[0-1][0-9]{1,2}-[0-3][0-9]{1,2}-[0-9]{4}$/,"%m-%d-%Y"],
      [/^[0-1][0-9]{1,2}-[0-3][0-9]{1,2}-[0-9]{2}$/,"%m-%d-%y"],
      [/^[0-3][0-9]{1,2}-[0-1][0-9]{1,2}-[0-9]{4}$/,"%d-%m-%Y"],
      [/^[0-3][0-9]{1,2}-[0-1][0-9]{1,2}-[0-9]{2}$/,"%d-%m-%y"],
      [/^[0-9]{4}\/[0-1][0-9]{1,2}\/[0-3][0-9]{1,2}$/,"%Y/%m/%d"],
      [/^[0-9]{2}\/[0-1][0-9]{1,2}\/[0-3][0-9]{1,2}$/,"%y/%m/%d"],
      [/^[0-9]{4}\/[0-3][0-9]{1,2}\/[0-1][0-9]{1,2}$/,"%Y/%d/%m"],
      [/^[0-9]{2}\/[0-3][0-9]{1,2}\/[0-1][0-9]{1,2}$/,"%y/%d/%m"],

      [/^[0-1][0-9]{1,2}\/[0-3][0-9]{1,2}\/[0-9]{4}$/,"%m/%d/%Y"],
      [/^[1-9]{1}\/[0-3][0-9]{1,2}\/[0-9]{4}$/, "%m/%d/%Y"],
      [/^[1-9]{1}\/[1-9]{1}\/[0-9]{4}$/, "%m/%d/%Y"],
      [/^[0-1][0-9]{1,2}\/[1-9]{1}\/[0-9]{4}$/, "%m/%d/%Y"],

      [/^[0-9]{4}-[0-1][0-9]{1,2}-[0-3][0-9]{1,2}$/,"%Y-%m-%d"],
      [/^[0-9]{2}-[0-1][0-9]{1,2}-[0-3][0-9]{1,2}$/,"%y-%m-%d"],
      [/^[0-9]{4}-[0-3][0-9]{1,2}-[0-1][0-9]{1,2}$/,"%Y-%d-%m"],
      [/^[0-9]{2}-[0-3][0-9]{1,2}-[0-1][0-9]{1,2}$/,"%y-%d-%m"],
      [/^\d{6}$/,"%y%m%d"],
      [/^\d{8}$/,"%Y%m%d"],
      [/^\d{8}$/,"%m%d%Y"]
    ]
    reg_ex_list.each do |regex|
      if regex[0].match value
        tmp_time = nil
        # A match, but might not be a valid date value
        # first round of elimination, if the value is out of range, it's not a valid date
        begin
          tmp_time = Date.strptime(value, regex[1]).to_time
        rescue
          next
        end
        # Ok, value not out of range, so we need to exclude values that are greater than the
        # current date, as the system will never be processing report dates beyond today's date,
        # and values that are beyond a 5 year difference from today's date are also treated as
        # invalid date values.  Only values within a 5 year difference from today's date are accepted as
        # true valid date values.
        time_year_diff = Time.now.year - tmp_time.year
        if time_year_diff >= 0 #&& time_year_diff <= 5
          new_value = "#{tmp_time}"
          break
        end
      end
    end
    if return_value_flag
      unless new_value.blank?
        return new_value
      else
        return original_value
      end
    else
      unless new_value.blank?
        return true
      else
        return false
      end
    end
  end

  # Method returns the new line string
  #
  # Method takes in the file and determines what its new line character is
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

  # Method checks for the presence of headers
  #
  # Method checks if a common header is present, if not then false, else true
  def has_headers? line
    if line.downcase.index('campusid') || line.downcase.index('campus_id') || line.downcase.index('building') ||
      line.downcase.index('bld') || line.downcase.index('loc_id')
      return true
    else
      return false
    end
  end

  # Method saves files paths to instance variables
  #
  # Method runs through the files and saves their file paths into instance variables for reference by other methods 
  def reorder_files
    files = Dir.glob(File.join(@dir,"*"))
    files.each{|f|
      @enroll_file     = f if f.downcase.index('enroll')
      @attendance_file = f if f.downcase.index('att')
      @ili_file        = f if f.downcase.index('ili') || f.downcase.index('h1n1')
    }
  end
end