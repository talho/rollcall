# == Schema Information
#
# Table name: rollcall_alarms
#
#  id                 :integer(4)      not null, primary key
#  school_id          :integer(4)
#  alarm_query_id     :integer(4)
#  alarm_severity     :string
#  deviation          :float
#  severity           :float
#  absentee_rate      :float
#  report_date        :date
#  created_at         :datetime
#  updated_at         :datetime
#  alarm_severity     :string
#  ignore_alarm       :boolean

class Rollcall::Alarm < ActiveRecord::Base
  belongs_to :school, :class_name => "Rollcall::School", :foreign_key => "school_id"
  belongs_to :alarm_query, :class_name => "Rollcall::AlarmQuery", :foreign_key => "alarm_query_id"

  self.table_name = "rollcall_alarms"
end
