module Rollcall
  module Models
    module User
      def self.included(base)
        base.has_many :schools_base, :class_name => "Rollcall::UserSchool"
        base.has_many :school_districts_base, :class_name => "Rollcall::UserSchoolDistrict"
        super # call ActiveRecord's own .included() method
      end
  
      # Method maps school districts to user     
      def school_districts      
        Rollcall::SchoolDistrict.for_user(self).order(:id)
      end      
  
      # Method maps schools to user      
      def schools
        Rollcall::School.for_user(self).order(:id)            
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
  
      # Method returns alarm queries associated with user
      #
      # @param options an object of parameters
      def alarm_queries(options={})        
        alarm = Rollcall::AlarmQuery
        results = []
        if options[:alarm_query_id].present?
          if options[:latest].present?    
            alarm = alarm.where(:user_id => self.id).last
          else
            alarm = alarm.where(:user_id => self.id).order(:name)
          end
        else          
          if options[:clone].present?
            alarm = alarm.where(:id => options[:alarm_query_id])
          else            
            alarm = alarm.last
          end
        end        
        results = alarm.all if alarm.is_a? ActiveRecord::Relation
        results = [alarm] if alarm.is_a? Rollcall::AlarmQuery
        results
      end
  
      # Method checks if user is a rollcall admin
      def is_rollcall_admin?
        is_admin?('rollcall')
      end
  
      # Method checks if user has rollcall application assigned to them
      def is_rollcall_user?
        has_application?(:rollcall)
      end
  
      # Method checks if user has rollcall nurse role
      def is_rollcall_nurse?
        has_role?(:nurse, 'rollcall')
      end
  
      # Method checks if user has epidemiologist role
      def is_rollcall_epi?
        has_role?(:epidemiologist, 'rollcall')
      end
  
      # Method checks if user has health officer role
      def is_rollcall_health_officer?
        has_role?(:health_officer, 'rollcall')
      end
  
      # Method performs simple or advanced search
      #
      # @param params search parameters
      def school_search(params)                        
        results = school_search_relation(params)
        results.all 
      end
      
      def school_search_relation(params)
        options = {:count_limit => (params[:page].present? ? params[:page].to_i : 1) * (params[:limit].present? ? params[:limit].to_i : 6), :count => 0}               
        
        district = params[:school_district].present? ? "sd.name in (:school_district)" : "(sd.name is not null or sd.name is null)"
        zip = params[:zip].present? ? "rollcall_schools.postal_code in (:zip)" : "(rollcall_schools.postal_code is not null or rollcall_schools.postal_code is null)"
        type = params[:school_type].present? ? "rollcall_schools.school_type in (:school_type)" : "(rollcall_schools.school_type is not null or rollcall_schools.school_type is null)"
        name = params[:school].present? ? "rollcall_schools.display_name in (:school)" : "(rollcall_schools.display_name is not null or rollcall_schools.display_name is null)"
                
        if params[:zip].blank? && params[:school_district].blank? && params[:school_type].blank? && params[:school].present?
          query = "#{name}"        
        elsif (params[:zip].present? || params[:school_district].present? || params[:school_type].present?)
          if (params[:zip].present? && params[:school_district].present?)
            query = "((#{district} or #{zip}) and #{type})"
          elsif params[:zip].present?
            query = "(#{zip} and #{type})"
          else
            query = "(#{district} and #{type})"
          end
          if params[:school].present?
            query += "or #{name}"
          end
        else
          query = "rollcall_schools.id is not null"
        end
        results = self.schools.where(query, params).reorder('rollcall_schools.display_name')
      end
  
      # Method returns students attached to user schools
      def students
        Rollcall::Student.find_all_by_school_id schools
      end
    end         
  end
end
