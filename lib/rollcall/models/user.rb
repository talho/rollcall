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
        Rollcall::SchoolDistrict.for_user(self).order(:name)
      end      
  
      # Method maps schools to user      
      def schools
        Rollcall::School.for_user(self).order(:display_name)
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
        school_search_relation(params)
      end
      
      def school_search_relation(params)
        district = params[:school_district].present? ? "sd.name in (:school_district)" : "false"
        zip = params[:zip].present? ? "rollcall_schools.postal_code in (:zip)" : "false"
        type = params[:school_type].present? ? "rollcall_schools.school_type in (:school_type)" : params[:zip].present? || params[:school_district].present? ? "true" : "false"
        name = "rollcall_schools.display_name in (:school)"
              
        query = []                  
        query << "#{name}" if params[:school].present?
        
        inner = "("
        inner += "(#{district} or #{zip}) and " if (params[:zip].present? || params[:school_district].present?)
        inner += "#{type})"
        query << inner if params[:zip].present? || params[:school_district].present? || params[:school_type].present?

        self.schools.where(query.join(' or '), params).reorder('rollcall_schools.display_name')
      end
  
      # Method returns students attached to user schools
      def students
        Rollcall::Student.find_all_by_school_id schools
      end
    end         
  end
end
