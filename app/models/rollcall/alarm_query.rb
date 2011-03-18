# == Schema Information
#
# Table name: alarm_queries
#
#  id                  :integer(4)      not null, primary key
#  user_id             :integer(4)
#  school_id           :integer(4)
#  query_params        :string(255)
#  name                :string(255)
#  severity_min        :integer(4)
#  severity_max        :integer(4)
#  deviation_threshold :integer(4)
#  deviation_min       :integer(4)
#  deviation_max       :integer(4)
#  alarm               :boolean
#

class Rollcall::AlarmQuery < Rollcall::Base
  belongs_to :user,   :class_name => "User"
  belongs_to :rrd,    :class_name => "Rollcall::Rrd"
  belongs_to :school, :class_name => "Rollcall::School"
  set_table_name "rollcall_alarm_queries"

  def generate_alarm
    if alarm_set
      result = create_alarm
    else
      result = false
    end
    return result
  end

  private

  def create_alarm
    # clear previous alarms and before generating new ones
    Rollcall::Alarm.find_all_by_alarm_query_id(id).each { |a| a.destroy }

    query = ActiveSupport::JSON.decode(query_params)

    return_success   = false
    begin
      data_set       = []
      test_data_date = Time.parse("09/01/2010")
      start_date     = query[:startdt].blank? ? test_data_date : Time.parse(query[:startdt])
      end_date       = query[:enddt].blank? ? Time.now : Time.parse(query[:enddt]) + 1.day
      lock_date      = end_date - 1.month
      days           = ((end_date - start_date) / 86400)
      total_enrolled = Rollcall::SchoolDailyInfo.find_by_school_id(school_id).total_enrolled
      alarm_count    = 0
      (0..days).each do |i|
        report_date  = (end_date - i.days).strftime("%Y-%m-%d")
        if query[:absent] == "Gross"
          student_info = Rollcall::StudentDailyInfo.find_all_by_school_id_and_report_date(school_id, report_date)
        else
          student_info = Rollcall::StudentDailyInfo.find_all_by_school_id_and_report_date_and_confirmed_illness(school_id, report_date, true)
        end
        unless student_info.blank?
          total_absent  = student_info.size
          data_set.push(total_absent)
          deviation     = calculate_deviation data_set
          severity      = (total_absent.to_f / total_enrolled.to_f)
          absentee_rate = severity * 100
          if (absentee_rate >= severity_min) ||
             (deviation_min <= deviation && deviation <= deviation_max)
            if(Time.parse(report_date) >= lock_date)
              if absentee_rate >= severity_max
                alarm_severity = 'extreme'
              elsif (severity_min + 2) < absentee_rate && absentee_rate < severity_max
                alarm_severity = 'severe'
              elsif severity_min <= absentee_rate && absentee_rate <= (severity_min + 2)
                alarm_severity = 'moderate'
              else
                alarm_severity = 'unknown'
              end
              Rollcall::Alarm.create(
                :school_id      => school_id,
                :alarm_query_id => id,
                :deviation      => deviation,
                :severity       => severity,
                :alarm_severity => alarm_severity,
                :absentee_rate  => absentee_rate,
                :report_date    => report_date
              )
              alarm_count += 1
            end
          end
        end
        break if alarm_count == 4
      end
      data_set.clear
    rescue
      return false
    end
    return_success = true unless Rollcall::Alarm.find_all_by_alarm_query_id(id).blank?
    return return_success
  end

  def calculate_deviation(data_set)
    deviation            = 0
    mean_avg             = 0
    data_mean_diff_total = 0
    data_set.each do |data_point|
      mean_avg += data_point.to_i
    end
    mean_avg = mean_avg / data_set.length
    data_set.each do |data_point|
      data_mean_diff_total += (data_point - mean_avg) ** 2
    end
    deviation = Math.sqrt((data_mean_diff_total / data_set.length))
    return deviation
  end
end
