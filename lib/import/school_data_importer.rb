require 'csv'
# Class is responsible for importing the data into the system appropriately
class SchoolDataImporter
  # Method sets global variables
  #
  # @param filename string the name of the csv file to import
  def initialize(filename)
    @filename     = filename unless filename.blank?
    @record       = nil
    @mapping      = self.class::MAPPING unless @filename.blank?
    @symptoms     = Rollcall::Symptom.all
    @schools      = []
    @school_year  = 0
    @linenum      = 0
  end

  # Method reads in the CSV file and checks the record and then processes it into the system
  def import_csv
    @records = CSV.read(@filename, :headers => true, :row_sep => :auto)
    unless @records.blank?
      @linenum = 0
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
      f      = File.new(File.dirname(__FILE__) + "/../../db/fixtures/schools.csv", 'a+')
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
    end
  end

  # Base method, is meant to be defined in derived classes
  #
  # @params rec   array  an array of records to process
  # @params attrs hash   an attribute hash{:key => value}
  def process_record(rec, attrs)
    # must be defined in derived class
    #puts "Write method to import #{rec}, #{attrs}"
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
    s_i           = []
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
        report_time = report_date.to_time
        if report_date.strftime("%a").downcase == "sat" || report_date.strftime("%a").downcase == "sun"
          s_i.push([(report_time + 1.day).to_i.to_s, 0, total_enrolled])
        else
          s_i.push([(report_time + 1.day).to_i.to_s, total_absent, total_enrolled])
        end
      end
    end
    begin
      s_i.sort!{|a,b| a.first <=> b.first}
    rescue
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