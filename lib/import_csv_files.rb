require 'fastercsv'
# EnrollmentImporter.new("/tmp/enrollment.csv").import_csv
# AttendanceImporter.new("/tmp/attendance.csv").import_csv
# IliImporter.new("/tmp/ili.csv").import_csv
class SchoolDataImporter
  def initialize(filename)
    @filename    = filename.downcase unless filename.blank?
    @linenum     = 0
    @record      = nil
    @mapping     = self.class::MAPPING unless @filename.blank?
    @symptoms    = Rollcall::Symptom.all
    @rrd_path    = Dir.pwd << "/rrd/"
    @rrd_tool    = ROLLCALL_RRDTOOL_CONFIG["rrdtool_path"] + "/rrdtool"
    @school_year = 0
  end

  def import_csv
    @linenum = 0
    FasterCSV.open(@filename, :headers => true, :row_sep => :auto) { |records|
      records.each { |rec|
        @record = rec
        @linenum += 1
        if @linenum == 1 && @filename.index('att')
          @school_year = Time.parse(rec["AbsenceDate"]).year
        end
        check_record(rec)
        seed_record(rec)
        process_record(rec, rec2attrs(rec)) if rec2attrs(rec) != false
      }
    }
  end

  def seed_record(rec)
    if @filename.index('att') && Rollcall::School.find_by_tea_id(rec["CampusID"]).blank?
      district_id = rec["CampusID"].slice(0, rec["CampusID"].length - 3)
      school_number = rec["CampusID"].slice(rec["CampusID"].length - 3, rec["CampusID"].length)
      school_type = ""
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

  def process_record(rec, attrs)
    # must be defined in derived class
    puts "Write method to import #{rec}, #{attrs}"
  end

  def tea_id2school_id(tea_id)
    begin
      Rollcall::School.find_by_tea_id(tea_id).id
    rescue
      false
    end
  end

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

  def check_record(rec)
    @mapping.each { |mapping|
      unless rec[mapping[:field_name]].blank?
        if mapping.has_key?(:format) && !mapping[:format].match(rec[mapping[:field_name]])
          raise SyntaxError, "invalid value for field #{mapping[:name]} [#{rec[mapping[:field_name]]}]",
          ["#{@filename}, line #{@linenum}", "SchoolDataImporter"]
        end
      end
    }
  end
end

class EnrollmentImporter < SchoolDataImporter
  EnrollmentImporter::MAPPING = [
    { :field_name => "EnrollDate",        :name => :report_date, :format => /^\d{4}-(?:0\d|1[012])-(?:0\d|1\d|2\d|3[01]) (\d{2}):(\d{2}):(\d{2})$/ },
    { :field_name => "CampusID",          :name => :school_id, :action => :tea_id2school_id, :format => /^\d+$/ },
    { :field_name => "SchoolName",        :name => :campus_name, :action => :ignoreCsvField },
    { :field_name => "CurrentEnrollment", :name => :total_enrolled, :format => /^\d+$/ }
  ]

  def process_record(rec, attrs)
    if attrs[:school_id]
      daily_info = Rollcall::SchoolDailyInfo.find_by_school_id_and_report_date(attrs[:school_id], attrs[:report_date])
      daily_info = Rollcall::SchoolDailyInfo.new if !daily_info
      daily_info.update_attributes(attrs)
      daily_info.save
    end
  end
end

class AttendanceImporter < SchoolDataImporter
  AttendanceImporter::MAPPING = [
    { :field_name => "AbsenceDate", :name => :report_date, :format => /^\d{4}-(?:0\d|1[012])-(?:0\d|1\d|2\d|3[01]) (\d{2}):(\d{2}):(\d{2})$/ },
    { :field_name => "CampusID", :name => :school_id, :action => :tea_id2school_id, :format => /^\d+$/ },
    { :field_name => "SchoolName", :name => :campus_name, :action => :ignoreCsvField },
    { :field_name => "Absent", :name => :total_absent, :format => /^\d+$/ }
  ]

  def process_record(rec, attrs)
    if @enrollment_file.blank?
      for file in Dir.glob(File.join(File.dirname(@filename),"*"))
        if file.downcase.index('enroll')
          @enrollment_file = file
        end
      end
      @enrollment_hash = {}
      FasterCSV.open(@enrollment_file, :headers => true){|records|
        records.each{|record|
          @enrollment_hash[record["CampusID"].to_i] = record["CurrentEnrollment"].to_i
        }
      }
    end
    begin
      tea_id                 = Rollcall::School.find_by_id(attrs[:school_id]).tea_id
      attrs[:total_enrolled] = @enrollment_hash[tea_id]
    rescue
      attrs[:total_enrolled] = nil
    end
    y           = Time.parse(attrs[:report_date]).year
    m           = Time.parse(attrs[:report_date]).month
    d           = Time.parse(attrs[:report_date]).day
    report_date = Time.gm(y, m, d)
    if ((report_date.strftime("%a").downcase == "sat" || report_date.strftime("%a").downcase == "sun") && attrs[:total_absent].to_i.blank?)
      RRD.update("#{@rrd_path}#{tea_id}_absenteeism.rrd", [(report_date + 1.day).to_i.to_s,0,attrs[:total_enrolled].to_i], "#{@rrd_tool}")
    else
      RRD.update("#{@rrd_path}#{tea_id}_absenteeism.rrd", [(report_date + 1.day).to_i.to_s,attrs[:total_absent].to_i,attrs[:total_enrolled].to_i], "#{@rrd_tool}")
      daily_info = Rollcall::SchoolDailyInfo.find_by_school_id_and_report_date(attrs[:school_id].to_i, attrs[:report_date])
      daily_info = Rollcall::SchoolDailyInfo.new if !daily_info
      daily_info.update_attributes(attrs)
      daily_info.save
    end
  end
end

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
    { :field_name => "Zip",         :name => :zip, :format => /^\d{5}(?:-\d{4})?$/ },
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

  
  def process_record(rec, attrs)
    student_attrs = {}
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
    #id: integer, report_date: date, grade: integer, confirmed_illness: boolean, created_at: datetime,
    #updated_at: datetime, cid: text, health_year: string, date_of_onset: date, temperature: float,
    #in_school: boolean, released: boolean, diagnosis: string, treatment: string, follow_up: date,
    #doctor: string, doctor_address: string, student_id: integer, report_time: datetime


    #id: integer, first_name: string, last_name: string, contact_first_name: string,
    #contact_last_name: string, address: string, zip: string, gender: string,
    #phone: string, race: integer, school_id: integer, student_number: string,
    #dob: date, created_at: datetime, updated_at: datetime
    if attrs[:description].blank? || attrs[:description].downcase.index('none')
      student_daily_attrs[:confirmed_illness] = false
    end
    student_daily_attrs[:report_time] = attrs[:report_date]
    description         = attrs[:description]

    daily_info = Rollcall::StudentDailyInfo.find_by_cid_and_report_date(student_daily_attrs[:cid], student_daily_attrs[:report_date])
    if !daily_info
      if student_attrs[:name].blank?
        first_name = ""
        last_name = ""
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

      student_attrs[:first_name] = first_name
      student_attrs[:last_name]  = last_name
      student_attrs[:contact_first_name] = contact_first_name
      student_attrs[:contact_last_name]  = contact_last_name
      student_attrs.delete :name
      student_attrs.delete :contact
      student_attrs.delete :description
      student = Rollcall::Student.find_by_student_number student_attrs[:student_number]
      student = Rollcall::Student.create student_attrs if student.blank?     
      student.update_attributes(student_attrs)
      student.save
      student_daily_attrs[:student] = student
      daily_info = Rollcall::StudentDailyInfo.new
      daily_info.update_attributes(student_daily_attrs)
    end
    daily_info.save
    add_symptoms(daily_info, description)
  end

private

  def add_symptoms(daily_info, str)
#    bad_symptoms = Array.new
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
#        symptom = @symptoms.find {|sym| sym.name.downcase.split(' ').each do |s| symptom_name.downcase.index(s.gsub('(','').gsub(')','')) end }
#        if symptom
#          Rollcall::StudentReportedSymptoms.create(:symptom => symptom, :student_daily_info => daily_info)
#        else
#          #bad_symptoms.push(symptom_name)
#        end
      } 
    end
#    if !bad_symptoms.empty?
#      raise SyntaxError, "invalid value(s) in field symptom [#{bad_symptoms.join(",")}]",
#        ["#{@filename}, line #{@linenum}", "SchoolDataImporter"]
#    end
  end

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

  def str2gender(str)
    unless str.blank?
      if str.downcase.index(/['female'|'f']/)
        return "F"
      elsif str.downcase.index(/['male'|'m']/)
        return "M"
      end
    else
      return false
    end
  end

  def str2phone(str)
    str.gsub(/[\D]/,'')    
  end

  def str2bool(str)
    if !str.blank? && str.downcase.index(/['true'|'t']/)
      return true
    else
      return false
    end
  end

  def str2temp(str)
    if str.blank?
      return 98
    else
      str.to_f
    end
  end

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