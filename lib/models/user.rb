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

    def saved_queries(options={})
      unless options[:r_id].blank?
        saved_queries = Rollcall::SavedQuery.find_all_by_user_id_and_rrd_id(id, options[:r_id])
        unless options[:clone].blank?
          saved_query   = saved_queries.last
          saved_queries = []
          saved_queries.push(saved_query)
        end
      else
        saved_queries = Rollcall::SavedQuery.find_all_by_user_id(id)
      end
      saved_queries
    end
  end

  Dispatcher.to_prepare do
    ::User.send(:include, Rollcall::User)
  end
end