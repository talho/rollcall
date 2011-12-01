require 'dispatcher'

module Rollcall
  module User
    def self.included(base)
      base.has_many :schools_base, :class_name => "Rollcall::UserSchool"
      base.has_many :school_districts_base, :class_name => "Rollcall::UserSchoolDistrict"
      super # call ActiveRecord's own .included() method
    end

    def school_districts
      if is_rollcall_admin? || is_super_admin?("rollcall")
        r = jurisdictions.admin("rollcall").map{|jur| jur.self_and_descendants.map{|j|j.school_districts}.flatten.uniq}.flatten.uniq
      else
        r = self.school_districts_base.map(&:school_district)
      end
      r.sort{|a,b| a.name.downcase <=> b.name.downcase}
    end

    def schools
      s = self.school_districts.map(&:schools).flatten
      if !is_rollcall_admin? && !is_super_admin?('rollcall')
        s = s & self.schools_base.map(&:school).flatten
      end
      s.uniq.sort{|a,b| a.display_name <=> b.display_name}
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

    def school_search(params)
      if params[:type] == "simple"
        results =  simple_school_search(params)
      else
        results = adv_school_search(params)
      end
      return results
    end
   
    def simple_school_search params
      unless params[:school_district].blank?
        district_id = Rollcall::SchoolDistrict.find_by_name(params[:school_district]).id
        schools.find_all{|s| s.district_id == district_id }
      else
        r = schools.find_all{|s| s.school_type == params[:school_type] } unless params[:school_type].blank?
        r = schools.find_all{|s| s.display_name == params[:school] } unless params[:school].blank?
        r = schools if params[:school].blank? && params[:school_type].blank?
        r = [r] unless r.kind_of?(Array)
        r
      end
    end

    def adv_school_search params
      r = []
      unless params[:school_district].blank?
        district_ids = Rollcall::SchoolDistrict.find_all_by_name(params[:school_district]).map(&:id)
        r += schools.find_all{|s| district_ids.include?(s.district_id)}
      end
      if !params[:school_type].blank? && !params[:zip].blank?
        r += schools.find_all{|s| params[:school_type].include?(s.school_type) && params[:zip].include?(s.postal_code)}
      elsif !params[:school_type].blank?
        r += schools.find_all{|s| params[:school_type].include?(s.school_type)}
      elsif !params[:zip].blank?
        r += schools.find_all{|s| params[:zip].include?(s.postal_code)}
      end
      if r.blank?
        unless params[:school].blank?
          r += schools.find_all{|s| params[:school].include?(s.display_name)}
        else
          r += schools
        end
      else
        r += schools.find_all{|s| params[:school].include?(s.display_name)} unless params[:school].blank?
        r.flatten!
      end
      r.uniq!
      r
    end
  end

  Dispatcher.to_prepare do
    ::User.send(:include, Rollcall::User)
  end
end
