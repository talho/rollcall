# == Schema Information
#
# Table name: schools
#
#  id            :integer(4)      not null, primary key
#  name          :string(255)
#  display_name  :string(255)
#  level         :string(255)
#  address       :string(255)
#  postal_code   :string(255)
#  school_number :integer(4)
#  district_id   :integer(4)
#  created_at    :datetime
#  updated_at    :datetime
#  region        :string(255)
#  school_type   :string(255)
#

class School < ActiveRecord::Base
  belongs_to :district, :class_name => "SchoolDistrict", :foreign_key => "district_id"
  has_many :absentee_reports

  before_create :set_display_name
  default_scope :order => "display_name"

  named_scope :with_alerts,
              :select => "distinct schools.*",
              :include => :absentee_reports,
              :conditions => ["(absentee_reports.absent / absentee_reports.enrolled) >= 0.11 AND absentee_reports.report_date >= ?", 30.days.ago],
              :order => "(absentee_reports.absent/absentee_reports.enrolled) desc"
    
  def average_absence_rate(date=nil)
    date=Date.today if date.nil?
    absentees=absentee_reports.for_date(date).map do |report|
      unless report.enrolled.blank?
        report.absent.to_f/report.enrolled.to_f
      else
        0
      end
    end
    unless absentees.empty?
      absentees.inject(&:+)/absentees.size
    else
      0
    end
  end

  def self.search(search)
    search_condition = "%" + search + "%"
    find(:all, :conditions => ['display_name LIKE ? OR postal_code LIKE ? OR school_type LIKE ?', search_condition, search_condition, search_condition])
  end

  private
  def set_display_name
    self.display_name = self.name if self.display_name.nil? || self.display_name.strip.blank?
  end
end
