# == Schema Information
#
# Table name: alarm_queries
#
#  id                  :integer(4)      not null, primary key
#  user_id             :integer(4)
#  query_params        :string(255)
#  name                :string(255)
#  severity_min        :integer(4)
#  severity_max        :integer(4)
#  deviation_threshold :integer(4)
#  deviation_min       :integer(4)
#  deviation_max       :integer(4)
#  alarm_set           :boolean
#  created_at          :datetime
#  updated_at          :datetime

class Rollcall::AlarmQuery < ActiveRecord::Base
  belongs_to :user,   :class_name => "::User"
  self.table_name = "rollcall_alarm_queries"

  # Method calls create_alarm if alarm_set
  #
  def generate_alarm    
    if alarm_set
      create_alarm
    else
      false
    end
  end

  private

  # Method creates alarms based off saved alarm_query for each school
  #
  def create_alarm
    Rollcall::Alarm.find_all_by_alarm_query_id(id).each { |a| a.destroy }
    query_params.gsub!("[]", "")
    query = {}
    unless query_params.blank?
      fs    = ActiveSupport::JSON.decode(query_params)
      if fs.is_a? String
        query = ActiveSupport::JSON.decode(fs).symbolize_keys
      elsif fs.is_a? Hash
        query = fs.symbolize_keys
      end
    end
    #schools = Rollcall::School.search(query, user)
    schools = user.school_search query
    schools.each { |school| create_alarms_for_school(school, query) }
    !Rollcall::Alarm.find_all_by_alarm_query_id(id).blank?
  end

  # Method creates alarms for specific school
  #
  # Method creates an alarms for school
  def create_alarms_for_school(school, query)
    @data_set      = []
    test_data_date = DateTime.strptime("08/01/#{(Time.now.month >= 8) ? Time.now.year : (Time.now.year - 1)}", "%m/%d/%Y")
    start_date     = query["startdt"].blank? ? test_data_date : DateTime.strptime(query["startdt"], "%m/%d/%Y")
    end_date       = query["enddt"].blank? ? Time.now : DateTime.strptime(query["enddt"], "%m/%d/%Y") + 1.day
    lock_date      = end_date - 12.months
    days           = ((end_date - start_date) / 86400)
    alarm_count    = 0
    begin       
    (0..days).each do |i|
      report_date = (end_date - i.days).strftime("%Y-%m-%d")
      alarm_count += 1 if create_alarm_for_date(school.id, report_date, lock_date, query[:absent])
      break if alarm_count == 4
    end
    rescue Exception=>e
      pp e.backtrace
    end
    @data_set.clear
  end

  # Method creates an alarm based on a date
  #
  # Method is called from create_alarms_for_school, and gets passed in a school_id.  Method builds alarm for school
  # based on the id.
  def create_alarm_for_date(school_id, report_date, lock_date, absent_func)
    school = Rollcall::School.find_by_id(school_id)
    if absent_func == "Gross"
      info = Rollcall::SchoolDailyInfo.find_by_school_id_and_report_date(school.id, report_date)
      if info.blank?
        total_absent = 0
      else
        total_absent = info.total_absent
      end
    else
      students = Rollcall::Student.find_all_by_school_id school.id
      info = Rollcall::StudentDailyInfo.find_all_by_student_id_and_report_date_and_confirmed_illness(students, report_date, true)
      if info.blank?
        total_asbent = 0
      else
        total_absent = info.size
      end
    end
    @data_set.push(total_absent)
    unless info.blank?
      sdi = Rollcall::SchoolDailyInfo.find_by_school_id_and_report_date(school.id, report_date)
      unless sdi.blank?
        total_enrolled = sdi.total_enrolled
      else
        begin
          total_enrolled = Rollcall::SchoolDailyInfo.find(
          :all,
          :conditions => ["school_id = ? AND report_date < ?", school.id, report_date],
          :order => "report_date").last.total_enrolled
        rescue
          total_enrolled = Rollcall::SchoolDailyInfo.find_by_school_id(school.id, :order => "report_date").total_enrolled  
        end
      end
      deviation      = calculate_deviation(@data_set)
      severity       = (total_absent.to_f / total_enrolled.to_f)
      absentee_rate  = severity * 100
      if (absentee_rate >= severity_min) || (deviation_min <= deviation && deviation <= deviation_max)
        if(Time.parse(report_date) >= lock_date)
          alarm = Rollcall::Alarm.create(
            :school_id      => school.id,
            :alarm_query_id => id,                                                                  
            :deviation      => deviation,
            :severity       => severity,
            :alarm_severity => calc_alarm_severity(absentee_rate),
            :absentee_rate  => absentee_rate,
            :report_date    => report_date
          )
          ra = RollcallAlert.new(
            :title   => "New Alarm for #{school.display_name}[#{alarm.alarm_severity}]",
            :message => "A new alarm of #{alarm.alarm_severity} severity has been created for #{school.display_name} on #{report_date}.",
            :author  => user,
            #:alarm   => alarm,
            :audiences => [Audience.new(:users => [user])]
          )          
          return ra.save
        end
      end
      return false
    end
  end

  # Method calculates the deviation
  #
  # Method calculates the deviation of a data set
  def calculate_deviation(data_set)
    deviation            = 0
    mean_avg             = 0
    data_mean_diff_total = 0
    data_set.each do |data_point|
      mean_avg += data_point.to_i
    end
    mean_avg = mean_avg / data_set.length
    data_set.each do |data_point|
      data_mean_diff_total += (data_point.to_i - mean_avg) ** 2
    end
    deviation = Math.sqrt((data_mean_diff_total / data_set.length))
    return deviation
  end

  # Method returns alarm severity
  #
  # Method returns severity as string
  def calc_alarm_severity(absentee_rate)
    if absentee_rate >= severity_max
      'extreme'
    elsif (severity_min + 2) < absentee_rate && absentee_rate < severity_max
      'severe'
    elsif severity_min <= absentee_rate && absentee_rate <= (severity_min + 2)
      'moderate'
    else
      'unknown'
    end
  end
end
