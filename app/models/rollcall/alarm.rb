# == Schema Information
#
# Table name: rollcall_alarms
#
#  id                 :integer(4)      not null, primary key
#  school_id          :integer(4)
#  saved_query_id     :integer(4)
#  alarm_severity     :string
#  deviation          :float
#  severity           :float
#  absentee_rate      :float
#  report_date        :date
#  created_at         :datetime
#  updated_at         :datetime
#

class Rollcall::Alarm < Rollcall::Base
  belongs_to :school, :class_name => "Rollcall::School", :foreign_key => "school_id"
  belongs_to :saved_query, :class_name => "Rollcall::SavedQuery", :foreign_key => "saved_query_id"
    
  set_table_name "rollcall_alarms"

  def self.generate_alarm(query)
    unless query.alarm_set
      result = create_alarm query
    else
      result = false
    end
    return result
  end

  def self.generate_alarms(user_id)
    saved_queries = Rollcall::SavedQuery.find_all_by_user_id(user_id)
    saved_queries.each do |saved_query|
      generate_alarm saved_query
    end
  end

  private

  def self.create_alarm query
    return_success   = false
    begin
      data_set       = []
      query_params   = query.query_params.split("|")
      params         = {}
      query_params.each do |param|
        params[:"#{param.split('=')[0]}"] = param.split('=')[1]
      end
      test_data_date = Time.parse("11/22/2010")
      start_date     = params[:startdt].blank? ? test_data_date : Time.parse(params[:startdt])
      end_date       = params[:enddt].blank? ? Time.now : Time.parse(params[:enddt]) + 1.day
      tea_id         = params[:tea_id]
      school_id      = Rollcall::School.find_by_tea_id(tea_id).id
      days           = ((end_date - start_date) / 86400)
      total_enrolled = Rollcall::SchoolDailyInfo.find_by_school_id(school_id).total_enrolled
      (0..days).each do |i|
        report_date = start_date + i.days
        unless params[:absent].blank?
          student_info = Rollcall::StudentDailyInfo.find_all_by_school_id_and_report_date_and_confirmed_illness(school_id, report_date, true)
        else
          student_info = Rollcall::StudentDailyInfo.find_all_by_school_id_and_report_date(school_id, report_date)
        end
        unless student_info.blank?
          total_absent  = student_info.size
          data_set.push(total_absent) 
          deviation     = calculate_deviation data_set
          severity      = (total_absent.to_f / total_enrolled.to_f)
          absentee_rate = severity * 100
          if (severity >= query.severity_min && severity <= query.severity_max) ||
             (deviation >= query.deviation_min && deviation <= query.deviation_max) ||
             (deviation >= query.deviation_threshold) ||
             ((query.deviation_threshold - deviation) <= 1)
            if absentee_rate >= query.severity_max
              alarm_severity = 'extreme'
            elsif absentee_rate > query.severity_min && absentee_rate < query.severity_max
              alarm_severity = 'severe'
            elsif absentee_rate > (query.severity_min - 2) && absentee_rate <= query.severity_min
              alarm_severity = 'moderate'
            else
              alarm_severity = 'unknown'
            end
            create(
              :school_id      => school_id,
              :saved_query_id => query.id,
              :deviation      => deviation,
              :severity       => severity,
              :alarm_severity => alarm_severity,
              :absentee_rate  => absentee_rate,
              :report_date    => report_date
            ) if find(:all, :conditions => ['saved_query_id = ? AND report_date = ?', query.id, report_date]).blank?
          end
        end
      end
      data_set.clear
    rescue
      return false
    end
    return_success = true unless find(:all, :conditions => ['saved_query_id = ?', query.id]).blank?
    return return_success
  end

  def self.calculate_deviation(data_set)
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