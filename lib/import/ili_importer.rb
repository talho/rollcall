require File.join(File.dirname(__FILE__), 'school_data_importer.rb')
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
    puts "Importing ILI Data for School ID: #{attrs[:school_id]}"
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
              unless daily_info.symptoms.map(&:name).include?(symptom.name)
                Rollcall::StudentReportedSymptom.create(:symptom => symptom, :student_daily_info => daily_info)
              end
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