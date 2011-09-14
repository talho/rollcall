require 'fastercsv'
# EnrollmentImporter.new("/tmp/enrollment.csv").import_csv
# AttendanceImporter.new("/tmp/attendance.csv").import_csv
# IliImporter.new("/tmp/ili.csv").import_csv
# Class is responsible for importing the data into the system appropriately
class SchoolDataImporter
  # Method sets global variables
  #
  # @param filename string the name of the csv file to import
  def initialize(filename)
    #@filename     = filename.downcase unless filename.blank?
    @filename     = filename unless filename.blank?
    @record       = nil
    @mapping      = self.class::MAPPING unless @filename.blank?
    @symptoms     = Rollcall::Symptom.all
    @rrd_path     = Dir.pwd << "/rrd/"
    @rrd_tool     = ROLLCALL_RRDTOOL_CONFIG["rrdtool_path"] + "/rrdtool"
    @school_year  = 0
    @linenum      = 0
  end

  # Method reads in the CSV file and checks the record, seeds it into rrd, and then processes it into the system
  def import_csv
    @records = FasterCSV.read(@filename, :headers => true, :row_sep => :auto)
    @linenum      = 0
    if @filename.index('att') || @filename.index('Att')
     @school_year = Time.parse(@records[0]["AbsenceDate"]).year
    end
    @records.each { |rec |
      @linenum += 1
      @record   = rec
      check_record(@record)
      seed_record(@record)
      process_record(@record, rec2attrs(@record)) if rec2attrs(@record) != false
    }
    if @filename.index('att') || @filename.index('Att')
      write_rrd_file
    end
  end

  # Method seeds the record if processing new school
  #
  # @param rec array an array of records to seed
  def seed_record(rec)
    if @filename.downcase.index('att') && Rollcall::School.find_by_tea_id(rec["CampusID"]).blank?
      district_id   = rec["CampusID"].slice(0, rec["CampusID"].length - 3)
      school_number = rec["CampusID"].slice(rec["CampusID"].length - 3, rec["CampusID"].length)
      school_type   = ""
      if rec["SchoolName"].downcase.index('high')
        school_type = "High School"
      end
      if rec["SchoolName"].downcase.index('elem')
        school_type = "Elementary School"
      end
      if rec["SchoolName"].downcase.index('jr') || rec["SchoolName"].downcase.index('middle')
        school_type = "Middle School"
      end
      if rec["SchoolName"].downcase.index('ecc') || rec["SchoolName"].downcase.index('kind') ||
        rec["SchoolName"].downcase.index('child') || rec["SchoolName"].downcase.index('early')
        school_type = "Kindergarten"
      end
      if rec["SchoolName"].downcase.index('jjaep') || rec["SchoolName"].downcase.index('alternative') ||
        rec["SchoolName"].downcase.index('juvenile')
        school_type = "Multilevel School"
      end
      string = "#{rec["SchoolName"]},#{district_id},#{school_number},#{rec["CampusID"]},#{school_type},,,''"
      f      = File.new(File.dirname(__FILE__) + "/../db/fixtures/schools.csv", 'a+')
      f.puts string
      f.close()

      #create school
      school = Rollcall::School.create(
        :display_name  => rec["SchoolName"],
        :tea_id        => rec["CampusID"],
        :district_id   => district_id,
        :school_number => school_number,
        :school_type   => school_type
      )
      #create rrd file for school
      Rollcall::Rrd.build_rrd(school.tea_id, school.id, Time.gm(@school_year,"aug",01,0,0))
    end
  end

  # Base method, is meant to be defined in derived classes
  #
  # @params rec   array  an array of records to process
  # @params attrs hash   an attribute hash{:key => value}
  def process_record(rec, attrs)
    # must be defined in derived class
    puts "Write method to import #{rec}, #{attrs}"
  end

  # Method returns the PK for school with tea_id
  #
  # @param tea_id string the tea id to search for
  def tea_id2school_id(tea_id)
    begin
      Rollcall::School.find_by_tea_id(tea_id).id
    rescue
      false
    end
  end

  # Method is called to tally and record total_absent and total_enrolled for the school district
  #
  # @param district object district object 
  def school_district_dailies district
    schools       = Rollcall::School.find_all_by_district_id district.id
    daily_results = Rollcall::SchoolDailyInfo.find_all_by_school_id schools
    dates         = daily_results.map{|m| m.report_date}.uniq
    dates.each do |i|
      report_date    = i
      total_absent   = 0
      total_enrolled = 0
      daily_results.map{|m|
        if m.report_date == report_date
          total_absent   += m.total_absent.to_i
          total_enrolled += m.total_enrolled.to_i
        end
      }
      if total_enrolled != 0
        absentee_rate  = (total_absent.to_f / total_enrolled.to_f)
        Rollcall::SchoolDistrictDailyInfo.create(
          :report_date        => report_date,
          :absentee_rate      => absentee_rate,
          :total_enrollment   => total_enrolled,
          :total_absent       => total_absent,
          :school_district_id => district.id
        )
      end
    end
  end

private

  # Method returns a new hash with correctly mapped values
  #
  # @param rec array the record to map
  def rec2attrs(rec)
    attrs = Hash.new
    @mapping.each { |mapping|
      if mapping[:action] == :ignoreCsvField || rec[mapping[:field_name]].blank?
        next
      end
      field = mapping[:name]
      if mapping[:action]
        attrs[field] = (mapping[:action].is_a?(Proc)) ? mapping[:action].call(rec[mapping[:field_name]]) : send(mapping[:action], rec[mapping[:field_name]])
      else
        attrs[field] = rec[mapping[:field_name]]
      end
    }
    attrs
  end

  # Method checks if record is valid against mapping format
  #
  # @param rec array the record to check
  def check_record(rec)
    @mapping.each { |mapping|
      unless rec[mapping[:field_name]].blank?
        if mapping.has_key?(:format) && !mapping[:format].match(rec[mapping[:field_name]])
          raise SyntaxError, "invalid value for field #{mapping[:name]} [#{rec[mapping[:field_name]]}]",
          ["#{@filename}, line #{@linenumber}", "SchoolDataImporter"]
        end
      end
    }
  end
end

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
      puts "Importing Enrollment Data for #{attrs[:campus_name]}"
      daily_info            = Rollcall::SchoolDailyInfo.find_by_school_id_and_report_date(attrs[:school_id], attrs[:report_date])
      daily_info            = Rollcall::SchoolDailyInfo.new if !daily_info
      daily_info.attributes = attrs
      daily_info.save
    end
  end
end

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
    puts "Importing Attendance Data for #{attrs[:school_id]}"
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
    Rollcall::School.find_in_batches(:batch_size => 100) do |schools|
      schools.each{|s|
        unless Rollcall::SchoolDailyInfo.find_by_school_id(s.id).blank?
          Rollcall::SchoolDailyInfo.find_in_batches(
            :conditions => ["school_id = ? AND created_at > ?", s.id, 1.day.ago.utc],
            :batch_size => 100
          ) do |recs|
            recs.each{|r|
              report_time = r.report_date.to_time
              if @s_i.blank?
                @s_i = [ [report_time.to_i.to_s, 0, recs[0].total_enrolled] ]
              end
              if r.report_date.strftime("%a").downcase == "sat" || r.report_date.strftime("%a").downcase == "sun"
                @s_i.push([(report_time + 1.day).to_i.to_s, 0, r.total_enrolled])
              else
                @s_i.push([(report_time + 1.day).to_i.to_s, r.total_absent, r.total_enrolled])
              end
              @end_time     = report_time
              @end_enrolled = r.total_enrolled
            }
          end
          begin
            @s_i.push([(@end_time + 2.days).to_i.to_s, 0, @end_enrolled])
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
      }
    end
  end
end

# Class is derived from SchoolDataImporter, imports ili data, defines MAPPING and process_record
class IliImporter < SchoolDataImporter
  IliImporter::MAPPING = [
    { :field_name => "CID",        :name => :cid, :school_daily_info => true },
    { :field_name => "HealthYear", :name => :health_year, :school_daily_info => true },
    { :field_name => "CampusID",   :name => :school_id,   :action => :tea_id2school_id, :format => /^\d+$/ },
    { :field_name => "CampusName", :name => :campus_name, :action => :ignoreCsvField },
    { :field_name => "OrigDate",   :name => :report_date, :school_daily_info => true, :format => /^\d{4}-(?:0\d|1[012])-(?:0\d|1\d|2\d|3[01]) (\d{2}):(\d{2}):(\d{2})$/ },

    { :field_name => "DateOfOnset", :name => :date_of_onset, :school_daily_info => true, :format => /^\d{4}-(?:0\d|1[012])-(?:0\d|1\d|2\d|3[01]) (\d{2}):(\d{2}):(\d{2})$/ },
    { :field_name => "Temperature", :name => :temperature, :school_daily_info => true, :action => :str2temp},
    { :field_name => "Symptoms",    :name => :description },
    { :field_name => "Zip",         :name => :zip, :action => :str2zip },
    { :field_name => "Grade",       :name => :grade, :school_daily_info => true, :action => :str2grade },

    { :field_name => "InSchool",  :name => :in_school, :school_daily_info => true, :action => :str2bool },
    { :field_name => "Confirmed", :name => :confirmed_illness, :school_daily_info => true, :action => :is_confirmed },
    { :field_name => "Released",  :name => :released, :school_daily_info => true, :action => :str2bool },
    { :field_name => "Diagnosis", :name => :diagnosis, :school_daily_info => true },
    { :field_name => "Treatment", :name => :treatment, :school_daily_info => true },

    { :field_name => "Name",      :name => :name },
    { :filed_name => "StudentID", :name => :student_number},
    { :field_name => "Contact",   :name => :contact },
    { :field_name => "Phone",     :name => :phone,  :action => :str2phone },
    { :field_name => "DOB",       :name => :dob,    :format => /^\d{4}-(?:0\d|1[012])-(?:0\d|1\d|2\d|3[01]) (\d{2}):(\d{2}):(\d{2})$/ },
    { :field_name => "Gender",    :name => :gender, :action => :str2gender },

    { :field_name => "Race",          :name => :race },
    { :field_name => "FollowUp",      :name => :follow_up, :school_daily_info => true },
    { :field_name => "Doctor",        :name => :doctor, :school_daily_info => true },
    { :field_name => "DoctorAddress", :name => :doctor_address, :school_daily_info => true }
  ]

  # Method processes record into Student, StudentDailyInfo and StudentReportedSymptom
  #
  # @params rec   array  an array of records to process
  # @params attrs hash   an attribute hash{:key => value}
  def process_record(rec, attrs)
    puts "Importing ILI Data for #{attrs[:school_id]}"
    student_attrs       = {}
    student_daily_attrs = {}
    @mapping.each { |mapping|
      if mapping[:action] == :ignoreCsvField || rec[mapping[:field_name]].blank?
        next
      end
      if mapping.has_key?(:school_daily_info)
        student_daily_attrs[mapping[:name]] = attrs[mapping[:name]]
      else
        student_attrs[mapping[:name]] = attrs[mapping[:name]]
      end
    }
    if attrs[:description].blank? || attrs[:description].downcase.index('none')
      student_daily_attrs[:confirmed_illness] = false
    else
      student_daily_attrs[:confirmed_illness] = true
    end
    student_daily_attrs[:report_time] = attrs[:report_date]
    description                       = attrs[:description]
    if student_attrs[:name].blank?
      first_name = ""
      last_name  = ""
    else
      if student_attrs[:name].split(",").length > 1
        first_name = student_attrs[:name].split(",").last
        last_name  = student_attrs[:name].split(",").first
      else
        first_name = student_attrs[:name].split(" ").first
        last_name  = student_attrs[:name].split(" ").last
      end
    end
    if student_attrs[:contact].blank?
      contact_first_name = ""
      contact_last_name  = ""
    else
      if student_attrs[:contact].split(",").length > 1
        contact_first_name = student_attrs[:contact].split(",").last
        contact_last_name  = student_attrs[:contact].split(",").first
      else
        contact_first_name = student_attrs[:contact].split(" ").first
        contact_last_name  = student_attrs[:contact].split(" ").last
      end
    end
    student_attrs[:first_name]         = first_name.strip
    student_attrs[:last_name]          = last_name.strip
    student_attrs[:contact_first_name] = contact_first_name.strip
    student_attrs[:contact_last_name]  = contact_last_name.strip
    student_attrs.delete :name
    student_attrs.delete :contact
    student_attrs.delete :description
    student = {}
    student = Rollcall::Student.find_by_student_number_and_school_id(student_attrs[:student_number],attrs[:school_id]) unless student_attrs[:student_number].blank?
    if student.blank?
      unless student_attrs[:student_number].blank?
        student = Rollcall::Student.find_by_first_name_and_last_name_and_contact_first_name_and_contact_last_name_and_school_id_and_student_number(
          student_attrs[:first_name],
          student_attrs[:last_name],
          student_attrs[:contact_first_name],
          student_attrs[:contact_last_name],
          attrs[:school_id],
          student_attrs[:student_number]
        )
      else
        student = Rollcall::Student.find_by_first_name_and_last_name_and_contact_first_name_and_contact_last_name_and_address_and_zip_and_gender_and_phone_and_race_and_dob_and_school_id(
          student_attrs[:first_name],
          student_attrs[:last_name],
          student_attrs[:contact_first_name],
          student_attrs[:contact_last_name],
          student_attrs[:address],
          student_attrs[:zip],
          student_attrs[:gender],
          student_attrs[:phone],
          student_attrs[:race],
          student_attrs[:dob],
          attrs[:school_id]
        )
      end
    end
    if student.blank?
      daily_info = Rollcall::StudentDailyInfo.find_by_cid_and_report_date(student_daily_attrs[:cid],student_daily_attrs[:report_date])
    else
      daily_info = Rollcall::StudentDailyInfo.find_by_cid_and_report_date_and_student_id(student_daily_attrs[:cid],student_daily_attrs[:report_date],student.id)
    end
    if !daily_info
      student = Rollcall::Student.create student_attrs if student.blank?     
      student.update_attributes(student_attrs)
      student.save
      student_daily_attrs[:student] = student
      daily_info                    = Rollcall::StudentDailyInfo.new
      daily_info.update_attributes(student_daily_attrs)
    end
    daily_info.save
    add_symptoms(daily_info, description)
  end

private

  # Method processes the recorded symtpom
  #
  # @param daily_info object a student_daily_info object
  # @param str        string a list of symptoms, seperated by commas
  def add_symptoms(daily_info, str)
    unless str.blank?
      str.split(",").each { |sym_name|
        symptom_name = sym_name.strip
        if symptom_name.downcase.index('rhino')
          symptom_name = 'congestion'
        end
        @symptoms.each {|symptom|
          symptom.name.downcase.split(' ').each do |sym|
            if symptom_name.downcase.index(sym.gsub('(','').gsub(')',''))
              Rollcall::StudentReportedSymptom.create(:symptom => symptom, :student_daily_info => daily_info)
              break
            end
          end
        }
      } 
    end
  end

  # Method returns the grade level as integer
  #
  # @param str string the grade level in string format
  def str2grade(str)
    grade_str = str.strip
    case grade_str
    when /^[0-9]/
      grade_str.to_i
    else
      if grade_str.downcase.index(/['pk']|['kg']|['kind']/)
        0  
      else
        return false
      end
    end
  end

  # Method returns the gender character representation
  #
  # @param str string the gender in string format
  def str2gender(str)
    unless str.blank?
      if str.downcase.index('female') || str.downcase.index('f')
        return "F"
      elsif str.downcase.index('male') || str.downcase.index('m')
        return "M"
      end
    else
      return false
    end
  end

  # Method returns phone number as integers
  #
  # @param str string the original phone number
  def str2phone(str)
    str.gsub(/[\D]/,'')    
  end

  # Method takes in true/false values as strings and returns boolean values
  #
  # @param str string the bool as string
  def str2bool(str)
    if !str.blank? && str.downcase.index(/['true'|'t']/)
      return true
    else
      return false
    end
  end

  # Method returns temperature as float value
  #
  # @param str string the temperature in string format
  def str2temp(str)
    if str.blank?
      return 98
    else
      str.to_f
    end
  end

  # Method returns zip as 5 digit value
  #
  # @param str zip the zipcode in string format
  def str2zip(str)
    zip = str[0..4]
    return zip
  end
  # Method checks if is confirmed illness based off temp and symptoms
  #
  # @param str string the confirmed illness field
  def is_confirmed(str)
    if !str.blank? && str.downcase.index(/['true'|'t']/)
      return true
    elsif @record["Temperature"].to_i >= 99
      return true
    elsif !@record["Symptoms"].blank? && @record["Symptoms"].downcase.index('temp')
      return true
    else
      return false
    end
  end
end