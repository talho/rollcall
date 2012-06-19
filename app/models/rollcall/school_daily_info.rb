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
class Rollcall::SchoolDailyInfo < ActiveRecord::Base
  SEVERITY = {
    :low    => {:min => 0.0,     :max => 0.10000},
    :medium => {:min => 0.11000, :max => 0.20000},
    :high   => {:min => 0.21000, :max => 1.0},
  }
  belongs_to :school, :class_name => "Rollcall::School", :foreign_key => "school_id"
  
  has_one :district, :through => :school
  
  self.table_name = "rollcall_school_daily_infos"

  #Scopes
  def self.for_date(date)
    where(:report_date => date)
  end
  
  def self.for_date_range(start, finish)
    where(:report_date => start..finish)
  end
  
  def self.recent(limit)
    order('report_date desc').limit(limit)
  end
  
  def self.absences
    where('CAST(rollcall_school_daily_infos.total_absent as FLOAT) / CAST(rollcall_school_daily_infos.total_enrolled as FLOAT) >= .11')
  end
  
  def self.with_severity(severity)
    range = SEVERITY[severity]
    where('(CAST(rollcall_school_daily_infos.total_absent as FLOAT) / CAST(rollcall_school_daily_infos.total_enrolled as FLOAT)) >= ?', range[:min])
      .where('(CAST(rollcall_school_daily_infos.total_absent as FLOAT) / CAST(rollcall_school_daily_infos.total_enrolled as FLOAT)) < ?', range[:max])
      .where("rollcall_school_daily_infos.total_enrolled is not null")
      .where("rollcall_school_daily_infos.total_enrolled <> 0")
  end

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