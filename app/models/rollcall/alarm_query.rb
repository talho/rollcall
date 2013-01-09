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
  belongs_to :user, :class_name => "::User"
  has_and_belongs_to_many :schools, :class_name => "Rollcall::School", :join_table => "rollcall_alarm_queries_schools"
  self.table_name = "rollcall_alarm_queries"
  
  validates_uniqueness_of :name, :scope => [:user_id]
      
  def generate_alarms
    insert = "insert into #{Rollcall::Alarm.table_name}"\
             "(school_id, alarm_query_id, alarm_severity, deviation, severity, absentee_rate,"\
             "report_date, created_at, updated_at) "
    
    params = get_query_params
    
    select = Rollcall::SchoolDailyInfo
             .joins("inner join (select stddev_pop(total_absent) as deviation, school_id as deviation_school_id from rollcall_school_daily_infos group by school_id) school_sd on deviation_school_id = school_id")
             .where("report_date between ? and ?", params[:start_date], params[:end_date])
             .where("school_id in (?)", params[:schools])
             .where("and (((cast(total_absent as double) / cast(total_enrolled as double) * 100) >= ?) or (@deviation not between ? and ?))", severity_min, deviation_min, deviation_max)
             .select("school_id, ?", id)
             .select(absentee_thang)
             .select("deviation")
             .select("(cast(total_absent as double) / cast(total_enrolled as double) as severity, ((cast(total_absent as double) / cast(total_enrolled as double) * 100) as absentee_rate")
             .select("report_date, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP")               
    
   Rollcall::Alarm.connection.execute insert + select.to_sql
  end
  
  def get_query_params
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
    
    query = query.with_indifferent_access
    
    query[:start_date] = (query[:startdt].present? ? DateTime.strptime(query[:startdt], "%m/%d/%Y") : 1.year.ago.strftime('%m/%d/%Y'))
    query[:end_date] = (query[:enddt].present? ? DateTime.strptime(query[:enddt], "%m/%d/%Y") : DateTime.now.strftime('%m/%d/%Y'))
    query[:schools] = schools.pluck(:id)
    
    query
  end
end