require 'dispatcher'

module Rollcall
  module User
    def school_districts
      jurisdictions.map{|jur| jur.school_districts}.flatten.uniq
    end

    def schools(options={})
      options={ :conditions => ["district_id in (?)", school_districts.map(&:id)], :order => "name"}.merge(options)
      School.find(:all, options)
      #    school_districts.map{|district| district.schools}.flatten.uniq
    end

    def recent_absentee_reports
      schools.map{|school| school.absentee_reports.absenses.recent(20).sort_by{|report| report.report_date}}.flatten.uniq[0..19].sort_by{|report| report.school_id}
    end
  end

  Dispatcher.to_prepare do
    ::User.send(:include, Rollcall::User)
  end
end