require 'fastercsv'


class SchoolDataImporter
  def initialize(filename)
    @filename = filename
    @mapping = self.class::MAPPING
  end

  def import_csv
    FasterCSV.open(@filename, :headers => false) { |records|
      records.each { |rec| process_record(rec, rec2attrs(rec)) }
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
      next if mapping[1] == :ignoreCsvField
      field = mapping[0]
      if mapping[1]
        attrs[field] = (mapping[1].is_a?(Proc)) ? mapping[1].call(rec[idx]) : send(mapping[1], rec[idx])
      else
        attrs[field] = rec[idx]
      end
    }
    attrs
  end
end


class EnrollmentImporter < SchoolDataImporter
  EnrollmentImporter::MAPPING = [
    [ :report_date ],
    [ :school_id, :tea_id2school_id ],
    [ :campus_name, :ignoreCsvField ],
    [ :total_enrolled ]
  ]

  def process_record(rec, attrs)
    puts attrs.inspect
    daily_info = Rollcall::SchoolDailyInfo.find_by_school_id_and_report_date(attrs[:school_id], attrs[:report_date])
    daily_info = Rollcall::SchoolDailyInfo.new if !daily_info
    daily_info.update_attributes(attrs)
    #daily_info.save
  end
end


class AttendanceImporter < SchoolDataImporter
  AttendanceImporter::MAPPING = [
    [ :report_date ],
    [ :school_id, :tea_id2school_id ],
    [ :campus_name, :ignoreCsvField ],
    [ :total_absent ]
  ]

  def process_record(rec, attrs)
    puts attrs.inspect
    daily_info = Rollcall::SchoolDailyInfo.find_by_school_id_and_report_date(attrs[:school_id], attrs[:report_date])
    daily_info = Rollcall::SchoolDailyInfo.new if !daily_info
    daily_info.update_attributes(attrs)
    #daily_info.save
  end
end

class IliImporter < SchoolDataImporter
  IliImporter::MAPPING = [
    [ :cid ],
    [ :health_year ],
    [ :school_id, :tea_id2school_id ],
    [ :campus_name, :ignoreCsvField ],
    [ :report_date ],

    [ :date_of_onset ],
    [ :temperature ],
    [ :description, :ignoreCsvField ],
    [ :zip ],
    [ :grade, :str2grade ],

    [ :in_school ],
    [ :confirmed_illness ],
    [ :released ],
    [ :diagnosis ],
    [ :treatment ],

    [ :name ],
    [ :contact ],
    [ :phone ],
    [ :dob ],
    [ :gender ],

    [ :race ],
    [ :follow_up ],
    [ :doctor ],
    [ :doctor_address ]
  ]

  def process_record(rec, attrs)
    puts attrs.inspect
    #daily_info = Rollcall::StudentDailyInfo.find_by_cid_and_report_date(attrs[:cid], attrs[:report_date])
    #daily_info = Rollcall::StudentDailyInfo.new if !daily_info
    #daily_info.update_attributes(attrs)
    #daily_info.save
    add_symptoms(nil, rec[7])
  end

private

  def add_symptoms(daily_info, str)
    str.split(",").each { |symptom_name|
      pp Rollcall::Symptom.find_by_name(symptom_name.strip)
      #Rollcall::StudentReportedSymptoms.new(
      #  :symptom => Rollcall::Symptom.find_by_name(symptom_name.strip),
      #  :student_daily_info => daily_info
      #)
    }
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
IliImporter.new("/tmp/ili.csv").import_csv
