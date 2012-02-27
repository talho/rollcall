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
        r = role_memberships.find(:all, :include => [:role, :jurisdiction], :conditions => {:role_id => [Role.admin('rollcall'), Role.superadmin('rollcall')]}).map(
          &:jurisdiction).map(
            &:self_and_descendants).flatten.uniq.map(
              &:school_districts).flatten.uniq
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
      is_admin?('rollcall')
    end

    def is_rollcall_user?
      has_application?(:rollcall)
    end

    def is_rollcall_nurse?
      has_role?(:nurse, 'rollcall')
    end

    def is_rollcall_epi?
      has_role?(:epidemiologist, 'rollcall')
    end

    def is_rollcall_health_officer?
      has_role?(:health_officer, 'rollcall')
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
      options = {:count_limit => (params[:page].to_i || 1) * (params[:limit].to_i || 6), :count => 0}
      unless params[:school_district].blank?
        district_id          = Rollcall::SchoolDistrict.find_by_name(params[:school_district]).id
        schools.find_all{|s|
          options[:count] += 1 if ([s.district_id] == district_id || [s.district_id].include?(district_id)) && options[:count] <= options[:count_limit]
          ([s.district_id] == district_id || [s.district_id].include?(district_id)) && (options[:count] - 1) <= options[:count_limit]
        }
      else
        r = schools.find_all{|s|
          options[:count] += 1 if (s.school_type == params[:school_type] || s.school_type.include?(params[:school_type])) && options[:count] <= options[:count_limit]
          (s.school_type == params[:school_type] || s.school_type.include?(params[:school_type])) && (options[:count] - 1) <= options[:count_limit]
        } unless params[:school_type].blank?
        r = schools.find_all{|s|
          options[:count] += 1 if (s.display_name == params[:school] || s.display_name.include?(params[:school])) && options[:count] <= options[:count_limit]
          (s.display_name == params[:school] || s.display_name.include?(params[:school])) && (options[:count] - 1) <= options[:count_limit]
        } unless params[:school].blank?
        r = schools if params[:school].blank? && params[:school_type].blank?
        r = [r] unless r.kind_of?(Array)
        r
      end
    end

    def compare a, b, options={}
      options[:count] += 1 if (a == b || a.include?(b)) && options[:count] <= options[:count_limit]
    end

    def adv_school_search params
      r       = []
      options = {:count_limit => (params[:page].to_i || 1) * (params[:limit].to_i || 6), :count => 0}
      unless params[:school_district].blank?
        district_ids = Rollcall::SchoolDistrict.find_all_by_name(params[:school_district]).map(&:id)
        r += schools.find_all{|s|
          options[:count] += 1 if (district_ids == s.district_id || district_ids.include?(s.district_id)) && options[:count] <= options[:count_limit]
          (district_ids == s.district_id || district_ids.include?(s.district_id)) && (options[:count] - 1) <= options[:count_limit]
        }
      end
      if !params[:school_type].blank? && !params[:zip].blank?
        r += schools.find_all{|s|
          options[:count] += 1 if (params[:school_type] == s.school_type || params[:school_type].include?(s.school_type)) && options[:count] <= options[:count_limit] && params[:zip].include?(s.postal_code)
          (params[:school_type] == s.school_type || params[:school_type].include?(s.school_type)) && (options[:count] - 1) <= options[:count_limit] && params[:zip].include?(s.postal_code)
        }
      elsif !params[:school_type].blank?
        r += schools.find_all{|s|
          options[:count] += 1 if (params[:school_type] == s.school_type || params[:school_type].include?(s.school_type)) && options[:count] <= options[:count_limit]
          (params[:school_type] == s.school_type || params[:school_type].include?(s.school_type)) && (options[:count] - 1) <= options[:count_limit]
        }
      elsif !params[:zip].blank?
        r += schools.find_all{|s|
          options[:count] += 1 if (params[:zip] == s.postal_code || params[:zip].include?(s.postal_code)) && options[:count] <= options[:count_limit]
          (params[:zip] == s.postal_code || params[:zip].include?(s.postal_code)) && (options[:count] - 1) <= options[:count_limit]
        }
      end
      if r.blank?
        unless params[:school].blank?
          r += schools.find_all{|s|
            options[:count] += 1 if (params[:school] == s.display_name || params[:school].include?(s.display_name)) && options[:count] <= options[:count_limit]
            (params[:school] == s.display_name || params[:school].include?(s.display_name)) && (options[:count] - 1) <= options[:count_limit]
          }
        else
          r += schools
        end
      else
        r += schools.find_all{|s|
          options[:count] += 1 if (params[:school] == s.display_name || params[:school].include?(s.display_name)) && options[:count] <= options[:count_limit]
          (params[:school] == s.display_name || params[:school].include?(s.display_name)) && (options[:count] - 1) <= options[:count_limit]
        } unless params[:school].blank?
        r.flatten!
      end
      r.uniq!
      r
    end

    def students
      Rollcall::Student.find_all_by_school_id schools
    end
  end

  Dispatcher.to_prepare do
    ::User.send(:include, Rollcall::User)
  end
end
