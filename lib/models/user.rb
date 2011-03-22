require 'dispatcher'

module Rollcall
  module User
    def school_districts
      jurisdictions.map{|jur| jur.school_districts}.flatten.uniq
    end

    def schools(options={})
      options={ :conditions => ["district_id in (?)", school_districts.map(&:id)], :order => "name"}.merge(options)
      Rollcall::School.find(:all, options)
    end

    def recent_absentee_reports
      schools.map{|school| school.absentee_reports.absenses.recent(20).sort_by{|report| report.report_date}}.flatten.uniq[0..19].sort_by{|report| report.school_id}
    end

    def alarm_queries(options={})
      unless options[:alarm_query_id].blank?
        alarm_queries = []
        unless options[:clone].blank?
          alarm_query = Rollcall::AlarmQuery.find(:all).last
        else
          alarm_query = Rollcall::AlarmQuery.find(options[:alarm_query_id])
        end
        alarm_queries.push(alarm_query)
      else
        unless options[:latest].blank?
          alarm_queries = Rollcall::AlarmQuery.find_all_by_user_id(id, :order => "created_at DESC", :limit => 1)
        else
          alarm_queries = Rollcall::AlarmQuery.find_all_by_user_id(id, :order => "name")
        end
      end
      alarm_queries
    end
  end

  Dispatcher.to_prepare do
    ::User.send(:include, Rollcall::User)
  end
end
