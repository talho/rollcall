require 'dispatcher'

module Rollcall
  module User
    def self.included(base)
      base.has_many :schools_base, :class_name => "Rollcall::UserSchool"
      base.has_many :school_districts_base, :class_name => "Rollcall::UserSchoolDistrict"
      super # call ActiveRecord's own .included() method
    end

    def school_districts
      if is_rollcall_admin?
        jurisdictions.map{|jur| jur.school_districts}.flatten.uniq
      else
        self.school_districts_base.map(&:school_district)
      end
    end

    def schools
      s = self.school_districts.map(&:schools).flatten
      s = s & self.schools_base.map(&:school).flatten unless is_rollcall_admin?
      s.uniq
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

    def to_json_results_rollcall(for_admin=false)
      rm = role_memberships.map{|rm| "#{rm.role.name} in #{rm.jurisdiction.name}"}
      rq = (for_admin) ? role_requests.unapproved.map{|rq| "#{rq.role.name} in #{rq.jurisdiction.name}"} : []     
      return {
        :user_id          => id, 
        :display_name     => display_name,
        :first_name       => first_name,
        :last_name        => last_name,
        :email            => email,
        :role_memberships => rm,
        :role_requests    => rq,
        :photo            => photo.url(:tiny),
        :schools          => schools,
        :school_districts => school_districts
      }
    end

    def is_rollcall_admin?
      if role_memberships.detect{ |rm| rm.role == Role.find_by_name_and_application('Admin', 'rollcall')}
        return true
      end
      return false
    end

    def is_rollcall_user?
      if role_memberships.detect{|rm| rm.role.application == Role.find_by_application('rollcall').application}
        return true
      else
        return false
      end
    end

    def is_rollcall_nurse?
      if role_memberships.detect{|rm| rm.role == Role.find_by_name_and_application('Nurse', 'rollcall')}
        return true
      else
        return false
      end
    end

    def is_rollcall_epi?
      if role_memberships.detect{|rm| rm.role == Role.find_by_name_and_application('Epidemiologist', 'rollcall')}
        return true
      else
        return false
      end
    end

    def is_rollcall_health_officer?
      if role_memberships.detect{ |rm| rm.role == Role.find_by_name_and_application('Health Officer', 'rollcall')}
        return true
      else
        return false
      end
    end
  end

  Dispatcher.to_prepare do
    ::User.send(:include, Rollcall::User)
  end
end
