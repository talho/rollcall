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
  # @param dir           the dir path
  # @param district_name the name of the district, matches folder name
  def initialize(dir, district_name)
    @dir                         = File.join(dir, district_name)
    @files                       = Dir.glob(File.join(@dir,"*"))
    @allowed_ili_headers         = nil
    @allowed_enrollment_headers  = nil
    @allowed_attendance_headers  = nil
    @delimiter                   = nil
    @quote_value                 = nil
    @no_headers                  = nil
    @six_digit_campus_id         = nil
    @has_8601_date               = nil
    @attendance_transform_fields = nil
    @enrollment_transform_fields = nil
    @ili_transform_fields        = nil
    @district                    = Rollcall::SchoolDistrict.find_by_name(district_name)
    # Load the interface fields yaml config file
    if File.exist?(doc_yml = File.join(Rails.root,"config","interface_fields.yml"))
      int_yml                  = YAML.load_file(doc_yml)
      @INTERFACE_FIELDS_CONFIG = int_yml
      @INTERFACE_FIELDS_CONFIG.freeze
    end
    unless @INTERFACE_FIELDS_CONFIG.blank?
      unless @INTERFACE_FIELDS_CONFIG["#{district_name}"].blank?
        fields                       = @INTERFACE_FIELDS_CONFIG["#{district_name}"]
        @allowed_ili_headers         = fields["permitted_ili_field_names"] if fields["permitted_ili_field_names"]
        @allowed_enrollment_headers  = fields["permitted_enrollment_field_names"] if fields["permitted_enrollment_field_names"]
        @allowed_attendance_headers  = fields["permitted_attendance_field_names"] if fields["permitted_attendance_field_names"]
        @delimiter                   = fields["delimiter"] unless fields["delimiter"].nil?
        @quote_value                 = fields["quote_value"] unless fields["quote_value"].blank?
        @no_headers                  = true if fields["no_headers"]
        @six_digit_campus_id         = false unless fields["six_digit_campus_id"]
        @has_8601_date               = true if fields["has_8601_date"]
        @attendance_transform_fields = fields["attendance_transform_fields"] if fields["attendance_transform_fields"]
        @enrollment_transform_fields = fields["enrollment_transform_fields"] if fields["enrollment_transform_fields"]
        @ili_transform_fields        = fields["ili_transform_fields"] if fields["ili_transform_fields"]
      end
      default_fields               = @INTERFACE_FIELDS_CONFIG["Default"]
      @allowed_ili_headers         = default_fields["permitted_ili_field_names"] if @allowed_ili_headers.blank?
      @allowed_enrollment_headers  = default_fields["permitted_enrollment_field_names"] if @allowed_enrollment_headers.blank?
      @allowed_attendance_headers  = default_fields["permitted_attendance_field_names"] if @allowed_attendance_headers.blank?
      @delimiter                   = default_fields["delimiter"] if @delimiter.nil?
      @quote_value                 = default_fields["quote_value"] if @quote_value.nil?
      @no_headers                  = false if @no_headers.blank?
      @six_digit_campus_id         = true if @six_digit_campus_id.nil?
      @has_8601_date               = false if @has_8601_date.blank?
      @attendance_transform_fields = [] if @attendance_transform_fields.blank?
      @enrollment_transform_fields = [] if @enrollment_transform_fields.blank?
      @ili_transform_fields        = [] if @ili_transform_fields.blank?
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
    transform @attendance_file, 'att' unless @attendance_file.blank?
    transform @enroll_file, 'enroll' unless @enroll_file.blank?
    transform @ili_file, 'ili' unless @ili_file.blank?
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
          #puts "Extracting #{file_path}: #{cmd}"
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
  def transform file_path, school_data_type
    if file_path.downcase.index('ads').blank? && !File.directory?(file_path)
      headers = @allowed_attendance_headers * "," if school_data_type == 'att'
      headers = @allowed_enrollment_headers * "," if school_data_type == 'enroll'
      headers = @allowed_ili_headers * ","        if school_data_type == 'ili'
      perform_enrollment_transform file_path      if school_data_type == 'enroll'
      file_name        = File.join(@dir, "the_temp_file.csv")
      file_to_write    = File.open(file_name, "w")
      line_number      = 1
      file_to_write.puts headers
      IO.foreach(file_path, sep_string = get_sep_string(file_path)) do |line|
        if ( (line_number == 1 && @no_headers) || (line_number > 1) ) && !line.blank?
          values   = []
          new_line = line.gsub(/["][^"]*["]/) { |m| m.gsub(',','|') if @delimiter != "|" }
          new_line.gsub!(/['][^']*[']/)       { |m| m.gsub(',','|') if @delimiter != "|" }
          new_line.gsub!(",","|") if @delimiter == "\t"
          new_line = new_line.gsub("\t", ",")
          if @delimiter != "\t" && @delimiter != "|" && @district.name != "Midland"
            new_line = new_line.gsub("','", '","')
            new_line = new_line.gsub(",'",',"')
            new_line = new_line.gsub(', ','|')
          end
          if @delimiter == "|"
            new_line = new_line.gsub(",",";") if school_data_type == 'ili'
            new_line = new_line.gsub("|",",")
          end
          value_pass = 1
          new_line.split(",").each do |value|
            if !value.blank?
              value.gsub!("|",",")
              value.gsub!('"',"'") if school_data_type != 'enroll'
              value.strip!
              #value.gsub!(@quote_value, "") if @quote_value == "'"
              value.gsub!("'",'')
              value.strip!
              if !@six_digit_campus_id && @attendance_transform_fields.include?(value_pass) && school_data_type == 'att'
                value = "0#{value}" if value.length == 2
                value = "00#{value}" if value.length == 1
                value = "#{@district.district_id}#{value}"
              end
              if is_date? value
                value = is_date? value, true
                value = "#{Time.parse(value).year}-#{Time.parse(value).month.to_s.rjust(2, '0')}-#{Time.parse(value).day.to_s.rjust(2, '0')} 00:00:00"
              end
              value.gsub!("T00:", " 00:") if @attendance_transform_fields.include?(value_pass) && @has_8601_date
              value.gsub!("T00:", " 00:") if @enrollment_transform_fields.include?(value_pass) && @has_8601_date
              value.gsub!("T00:", " 00:") if @ili_transform_fields.include?(value_pass) && @has_8601_date
              values.push('"'+value+'"')  if school_data_type != 'enroll'
              values.push(value)          if school_data_type == 'enroll'
            elsif value.blank? && school_data_type == 'ili'
              value.strip!
              values.push('"'+value+'"')
            end
            value_pass += 1
          end
          file_to_write.puts values.join(",")
        end
        line_number += 1 unless line.blank?
      end
      file_to_write.close
      File.rename(file_path, file_path+".tmp")
      File.rename(file_name, file_path)
      File.delete(file_path+".tmp")
    end
  end

  # Method initiates the transformation of the enrollment file if it does not meet interface specifications,
  # Attendance and Enrollment should both have equal amount of records, they both should have equal report dates
  def perform_enrollment_transform file_path
    IO.foreach(file_path, sep_string = get_sep_string(file_path)) do |line|
      tmp_line = line.split(@delimiter)
      if tmp_line.length < 4
        transform_enrollment_file
        break
      elsif transform_enrollment_file?
        transform_enrollment_file
        break
      end
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
    att_line_array = att_array.first.split(",")
    att_line_array = att_array.first.split("\t") if att_line_array.blank?
    enr_line_array = enr_array.first.split(",")
    enr_line_array = enr_array.first.split("\t") if enr_line_array.blank?
    begin
      transform = Time.parse(att_line_array.first) != Time.parse(enr_line_array.first)
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
    #puts "Transforming enrollment file for #{@district.name}"
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
      date,@tmp_tea_id,absent             = rec.split(",") if @allowed_attendance_headers.length == 3
      date,@tmp_tea_id,school_name,absent = rec.split(",") if @allowed_attendance_headers.length == 4
      if date.downcase.index("date").blank?
        enr_array.each do |line|
          @enrolled = 0
          tmp_line  = line.split(@delimiter)
          if tmp_line.length == 3
            if is_date?(tmp_line.first.gsub('"',''))
              enroll_date,tea_id,enrolled = tmp_line
            else
              tea_id,name,enrolled = tmp_line
            end           
          elsif tmp_line.length == 4
            enroll_date,tea_id,name,enrolled = tmp_line  
          end
          unless @six_digit_campus_id
            tea_id = "0#{value}"  if tea_id.length == 2
            tea_id = "00#{value}" if tea_id.length == 1
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
    if value.split("/").length == 3 && return_value_flag
      vsplit = value.split("/")
      if vsplit.last.length == 4 && (vsplit.last[0] == "0" && vsplit.last[1] == "0")
        value = "#{vsplit[0]}/#{vsplit[1]}/20#{vsplit.last[2]}#{vsplit.last[3]}"
      end
    end
    value          = "0#{original_value}" if value.length == 7 && value.to_i.to_s.length == 7
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