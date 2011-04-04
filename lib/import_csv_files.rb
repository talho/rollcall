require 'fastercsv'


class SchoolDataImporter
  def initialize(filename)
    @filename = filename
    @linenum = 0
    @mapping = self.class::MAPPING
    @symptoms = Rollcall::Symptom.all
  end

  def import_csv
    @linenum = 0
    FasterCSV.open(@filename, :headers => false) { |records|
      records.each { |rec|
        @linenum += 1
        check_record(rec)
        process_record(rec, rec2attrs(rec))
      }
    }
  end

  def process_record(rec, attrs)
    # must be defined in derived class
    puts "Write method to import #{rec}, #{attrs}"
  end

  def tea_id2school_id(tea_id)
    Rollcall::School.find_by_tea_id(tea_id).id
  end

private

  def rec2attrs(rec)
    attrs = Hash.new
    @mapping.each_with_index { |mapping,idx|
      next if mapping[:action] == :ignoreCsvField
      field = mapping[:name]
      if mapping[:action]
        attrs[field] = (mapping[:action].is_a?(Proc)) ? mapping[:action].call(rec[idx]) : send(mapping[:action], rec[idx])
      else
        attrs[field] = rec[idx]
      end
    }
    attrs
  end

  def check_record(rec)
    @mapping.each_with_index { |mapping,idx|
      if mapping.has_key?(:format) && !mapping[:format].match(rec[idx])
        raise SyntaxError, "invalid value for field #{mapping[:name]} [#{rec[idx]}]",
          ["#{@filename}, line #{@linenum}", "SchoolDataImporter"]
      end
    }
  end
end


class EnrollmentImporter < SchoolDataImporter
  EnrollmentImporter::MAPPING = [
    { :name => :report_date, :format => /^\d{4}-(?:0\d|1[12])-(?:0\d|1\d|2\d|3[01])$/ },
    { :name => :school_id, :action => :tea_id2school_id, :format => /^\d+$/ },
    { :name => :campus_name, :action => :ignoreCsvField },
    { :name => :total_enrolled, :format => /^\d+$/ }
  ]

  def process_record(rec, attrs)
    daily_info = Rollcall::SchoolDailyInfo.find_by_school_id_and_report_date(attrs[:school_id], attrs[:report_date])
    daily_info = Rollcall::SchoolDailyInfo.new if !daily_info
    daily_info.update_attributes(attrs)
    daily_info.save
  end
end


class AttendanceImporter < SchoolDataImporter
  AttendanceImporter::MAPPING = [
    { :name => :report_date, :format => /^\d{4}-(?:0\d|1[12])-(?:0\d|1\d|2\d|3[01])$/ },
    { :name => :school_id, :action => :tea_id2school_id, :format => /^\d+$/ },
    { :name => :campus_name, :action => :ignoreCsvField },
    { :name => :total_absent, :format => /^\d+$/ }
  ]

  def process_record(rec, attrs)
    daily_info = Rollcall::SchoolDailyInfo.find_by_school_id_and_report_date(attrs[:school_id], attrs[:report_date])
    daily_info = Rollcall::SchoolDailyInfo.new if !daily_info
    daily_info.update_attributes(attrs)
    daily_info.save
  end
end

class IliImporter < SchoolDataImporter
  IliImporter::MAPPING = [
    { :name => :cid },
    { :name => :health_year },
    { :name => :school_id, :action => :tea_id2school_id, :format => /^\d+$/ },
    { :name => :campus_name, :action => :ignoreCsvField },
    { :name => :report_date, :format => /^\d{4}-(?:0\d|1[12])-(?:0\d|1\d|2\d|3[01])$/ },

    { :name => :date_of_onset },
    { :name => :temperature },
    { :name => :description, :action => :ignoreCsvField },
    { :name => :zip },
    { :name => :grade, :action => :str2grade },

    { :name => :in_school },
    { :name => :confirmed_illness },
    { :name => :released },
    { :name => :diagnosis },
    { :name => :treatment },

    { :name => :name },
    { :name => :contact },
    { :name => :phone },
    { :name => :dob },
    { :name => :gender },

    { :name => :race },
    { :name => :follow_up },
    { :name => :doctor },
    { :name => :doctor_address }
  ]

  def process_record(rec, attrs)
    daily_info = Rollcall::StudentDailyInfo.find_by_cid_and_report_date(attrs[:cid], attrs[:report_date])
    daily_info = Rollcall::StudentDailyInfo.new if !daily_info
    daily_info.update_attributes(attrs)
    daily_info.save
    add_symptoms(daily_info, rec[7])
  end

private

  def add_symptoms(daily_info, str)
    bad_symptoms = Array.new
    str.split(",").each { |sym_name|
      symptom_name = sym_name.strip
      symptom = @symptoms.find { |sym| sym.name.downcase == symptom_name.downcase }
      if symptom
        Rollcall::StudentReportedSymptoms.new(:symptom => symptom, :student_daily_info => daily_info)
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
      raise "bad grade string"
    end
  end
end


#EnrollmentImporter.new("/tmp/enrollment.csv").import_csv
#AttendanceImporter.new("/tmp/attendance.csv").import_csv
#IliImporter.new("/tmp/ili.csv").import_csv
