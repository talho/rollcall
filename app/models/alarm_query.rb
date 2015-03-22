# == Schema Information
#
# Table name: alarm_queries
#
#  id                  :integer(4)      not null, primary key
#  user_id             :integer(4)
#  name                :string(255)
#  severity            :integer(4)
#  deviation_threshold :integer(4)
#  deviation           :integer(4)
#  alarm_set           :boolean
#  start_date          :datetime
#  created_at          :datetime
#  updated_at          :datetime

class AlarmQuery < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :schools
  has_and_belongs_to_many :school_districts

  validates_uniqueness_of :name, :scope => [:user_id]

  def generate_alarms
    if (start_date.blank?)
      self.start_date = DateTime.now
      self.save
    end

    insert = "insert into #{Rollcall::Alarm.table_name} (school_id, alarm_query_id, alarm_severity, deviation, severity, absentee_rate, report_date, created_at, updated_at) "

    select = Rollcall::SchoolDailyInfo
      .joins('inner join (select (total_absent - avg) / stddev_pop  as "z-score", s.report_date as "zreport_date", s.school_id as "zschool_id" from rollcall_school_daily_infos s inner join (select Avg(total_absent), stddev_pop(total_absent), school_id from rollcall_school_daily_infos group by school_id having stddev_pop(total_absent) <> 0) sd on sd.school_id = s.school_id where total_absent <> 0) as z on zschool_id = school_id and zreport_date = report_date')
      .where("report_date >= ?", start_date)
      .where("school_id in (?)", schools.pluck(:id))
      .where("(((cast(total_absent as float) / cast(total_enrolled as float) * 100) >= ?) or (\"z-score\" >= ? and ? > 0))", severity, deviation, deviation)
      .where("cast(total_enrolled as float) <> 0")
      .select("school_id, #{id} as alarm_query_id")
      .select("(cast(total_absent as float) / cast(total_enrolled as float)) as alarm_severity")
      .select('"z-score" as deviation')
      .select('(cast(total_absent as float) / cast(total_enrolled as float) * 100) as severity')
      .select("(cast(total_absent as float) / cast(total_enrolled as float) * 100) as absentee_rate")
      .select("report_date, CURRENT_TIMESTAMP as created_at, CURRENT_TIMESTAMP as updated_at")

    Rollcall::Alarm.connection.execute insert + select.to_sql
  end
end
