# == Schema Information
#
# Table name: rollcall_school_daily_infos
#
#  id              :integer      not null, primary key
#  school_id       :integer      not null, foreign key
#  total_absent    :integer      not null
#  total_enrolled  :integer      not null
#  report_date     :date         not null
#  created_at      :datetime
#  updated_at      :datetime
#
class Rollcall::SchoolDailyInfo < Rollcall::Base
  SEVERITY = {
    :low    => {:min => 0.0,     :max => 0.10000},
    :medium => {:min => 0.11000, :max => 0.20000},
    :high   => {:min => 0.21000, :max => 1.0},
  }
  belongs_to :school, :class_name => "Rollcall::School", :foreign_key => "school_id"
  
  has_one :district, :through => :school

  named_scope :for_date, lambda{|date|{
    :conditions => {:report_date => date}
  }}
  named_scope :for_date_range, lambda{ |start, finish|{
    :conditions => ["report_date >= ? and report_date <= ?", start, finish],
    :order      => "report_date desc"
  }}
  named_scope :recent, lambda{|limit| {
    :limit => limit,
    :order => "report_date DESC"
  }}
  named_scope :absences, lambda{{
    :conditions => ['CAST(total_absent as FLOAT) / CAST(total_enrolled as FLOAT) >= .11']
  }}
  named_scope :with_severity, lambda{|severity|
    range = SEVERITY[severity]
    {:conditions => ["(CAST(total_absent as FLOAT) / CAST(total_enrolled as FLOAT)) >= ? and (CAST(total_absent as FLOAT) / CAST(total_enrolled as FLOAT)) < ?", range[:min], range[:max]]}
  }
  
  set_table_name "rollcall_school_daily_infos"

  # Method returns absentee percentage
  def absentee_percentage
    ((total_absent.to_f / total_enrolled.to_f) * 100).to_f.round(2)
  end

  # Method returns severity
  #
  # Method returns severity as string depending on absentee percentage
  def severity
    return "low"    if absentee_percentage >= (SEVERITY[:low][:min]*100) && absentee_percentage < (SEVERITY[:low][:max]*100)
    return "medium" if absentee_percentage >= (SEVERITY[:medium][:min]*100) && absentee_percentage < (SEVERITY[:medium][:max]*100)
    return "high"   if absentee_percentage >= (SEVERITY[:high][:min]*100)
  end
end