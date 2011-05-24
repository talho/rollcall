require 'fastercsv'

class SchoolDataImporter
  def initialize(filename)
    @filename = filename
    @linenum  = 0
    @mapping  = self.class::MAPPING
    @symptoms = Rollcall::Symptom.all
    @rrd_path = Dir.pwd << "/rrd/"
    @rrd_tool = if File.exist?(doc_yml = RAILS_ROOT+"/vendor/plugins/rollcall/config/rrdtool.yml")
      YAML.load(IO.read(doc_yml))[Rails.env]["rrdtool_path"] + "/rrdtool"
    else
      "rrdtool"
    end
  end

  def import_csv
    @linenum = 0
    FasterCSV.open(@filename, :headers => true) { |records|
      records.each { |rec|
        @linenum += 1
        check_record(rec)
        process_record(rec, rec2attrs(rec)) if rec2attrs(rec) != false
      }
    }
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

private

  def rec2attrs(rec)
    attrs = Hash.new
    @mapping.each { |mapping|
      next if mapping[:action] == :ignoreCsvField
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
      if mapping.has_key?(:format) && !mapping[:format].match(rec[mapping[:field_name]])
        raise SyntaxError, "invalid value for field #{mapping[:name]} [#{rec[mapping[:field_name]]}]",
          ["#{@filename}, line #{@linenum}", "SchoolDataImporter"]
      end
    }
  end
end

class EnrollmentImporter < SchoolDataImporter
  EnrollmentImporter::MAPPING = [
    { :field_name => "EnrollDate",        :name => :report_date, :format => /^\d{4}-(?:0\d|1[012])-(?:0\d|1\d|2\d|3[01])$/ },
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
    { :field_name => "AbsenseDate", :name => :report_date, :format => /^\d{4}-(?:0\d|1[012])-(?:0\d|1\d|2\d|3[01]) (\d{2}):(\d{2}):(\d{2})$/ },
    { :field_name => "CampusID", :name => :school_id, :action => :tea_id2school_id, :format => /^\d+$/ },
    { :field_name => "SchoolName", :name => :campus_name, :action => :ignoreCsvField },
    { :field_name => "Absent", :name => :total_absent, :format => /^\d+$/ }
  ]

  def process_record(rec, attrs)
    if @enrollment_file.blank?
      @enrollment_file = @filename.gsub("Attendance", "Enrollment")
      @enrollment_hash = {}
      FasterCSV.open(@enrollment_file, :headers => false, :col_sep => "\t"){|records|
        records.each{|record|
          @enrollment_hash[record[0].to_i] = record[2].to_i
        }
      }
    end
    tea_id                 = Rollcall::School.find_by_id(attrs[:school_id]).tea_id
    attrs[:total_enrolled] = @enrollment_hash[tea_id]
    y                      = Time.parse(attrs[:report_date]).year
    m                      = Time.parse(attrs[:report_date]).month
    d                      = Time.parse(attrs[:report_date]).day
    report_date            = Time.gm(y, m, d)

    if report_date.strftime("%a").downcase == "sat" || report_date.strftime("%a").downcase == "sun"
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
    { :field_name => "CID",        :name => :cid },
    { :field_name => "HealthYear", :name => :health_year },
    { :field_name => "CampusID",   :name => :school_id,   :action => :tea_id2school_id, :format => /^\d+$/ },
    { :field_name => "CampusName", :name => :campus_name, :action => :ignoreCsvField },
    { :field_name => "OrigDate",   :name => :report_date, :format => /^\d{4}-(?:0\d|1[012])-(?:0\d|1\d|2\d|3[01]) (\d{2}):(\d{2}):(\d{2})$/ },

    { :field_name => "DateOfOnset", :name => :date_of_onset, :format => /^\d{4}-(?:0\d|1[012])-(?:0\d|1\d|2\d|3[01]) (\d{2}):(\d{2}):(\d{2})$/ },
    { :field_name => "Temperature", :name => :temperature, :action => :str2temp},
    { :field_name => "Symptoms",    :name => :description, :action => :ignoreCsvField },
    { :field_name => "Zip",         :name => :zip,         :format => /^\d{5}(?:-\d{4})?$/ },
    { :field_name => "Grade",       :name => :grade,       :action => :str2grade },

    { :field_name => "InSchool",  :name => :in_school,         :action => :str2bool },
    { :field_name => "Confirmed", :name => :confirmed_illness, :action => :str2bool },
    { :field_name => "Released",  :name => :released,          :action => :str2bool },
    { :field_name => "Diagnosis", :name => :diagnosis },
    { :field_name => "Treatment", :name => :treatment },

    { :field_name => "Name",    :name => :name },
    { :field_name => "Contact", :name => :contact },
    { :field_name => "Phone",   :name => :phone,  :action => :str2phone },
    { :field_name => "DOB",     :name => :dob,    :format => /^\d{4}-(?:0\d|1[012])-(?:0\d|1\d|2\d|3[01]) (\d{2}):(\d{2}):(\d{2})$/ },
    { :field_name => "Gender",  :name => :gender, :action => :str2gender },

    { :field_name => "Race",          :name => :race },
    { :field_name => "FollowUp",      :name => :follow_up },
    { :field_name => "Doctor",        :name => :doctor },
    { :field_name => "DoctorAddress", :name => :doctor_address }
  ]

  def process_record(rec, attrs)
    if rec[7].blank? || rec[7].downcase.index('none')
      attrs[:confirmed_illness] = false
    end
    attrs[:report_time] = attrs[:report_date]
    daily_info          = Rollcall::StudentDailyInfo.find_by_cid_and_report_date(attrs[:cid], attrs[:report_date])
    daily_info          = Rollcall::StudentDailyInfo.new if !daily_info
    daily_info.update_attributes(attrs)
    daily_info.save
    add_symptoms(daily_info, rec[7])
  end

private

  def add_symptoms(daily_info, str)
    bad_symptoms = Array.new
    str.split(",").each { |sym_name|
      symptom_name = sym_name.strip
      if symptom_name.downcase.index('rhino')
        symptom_name = 'congestion'
      end
      symptom = @symptoms.find {|sym| symptom_name.downcase.index(sym.name.downcase)}
      if symptom
        Rollcall::StudentReportedSymptoms.create(:symptom => symptom, :student_daily_info => daily_info)
      else
        bad_symptoms.push(symptom_name)
      end
    }
    if !bad_symptoms.empty?
      raise SyntaxError, "invalid value(s) in field symptom [#{bad_symptoms.join(",")}]",
        ["#{@filename}, line #{@linenum}", "SchoolDataImporter"]
    end
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
      str
    end
  end
end
#EnrollmentImporter.new("/tmp/enrollment.csv").import_csv
#AttendanceImporter.new("/tmp/attendance.csv").import_csv
#IliImporter.new("/tmp/ili.csv").import_csv