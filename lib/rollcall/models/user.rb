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
      
      # Creates a query for searching out schools based on passed parameters
      # Query will look something like:
      # WHERE :name or ((:district or :zip) and :type)
      def school_search_relation(params)
        query = []
        query << "rollcall_schools.display_name in (:school)" if params[:school].present?
        
        district_zip_query = [] # district and zip are non exclusive, included in the complete query via an or
        district_zip_query << "sd.name in (:school_district)" if params[:school_district].present?
        district_zip_query << "rollcall_schools.postal_code in (:zip)" if params[:zip].present?
        
        dz_school_type_query = []
        dz_school_type_query << "(#{district_zip_query.join(' or ')})" unless district_zip_query.blank? # The or part of district and zip
        dz_school_type_query << "rollcall_schools.school_type in (:school_type)" if params[:school_type].present? # School type modifies district and zip (or runs on its own)
        
        query << "(#{dz_school_type_query.join(' and ')})" unless dz_school_type_query.blank? # That entire sub-statement is anded together and added to the complete query

        self.schools.where(query.join(' or '), params).reorder('rollcall_schools.display_name')
      end
  
      # Method returns students attached to user schools
      def students
        Rollcall::Student.find_all_by_school_id schools
      end
      
      def rollcall_zip_codes
      self.schools
        .select("rollcall_schools.postal_code")
        .where("rollcall_schools.postal_code is not null")
        .reorder("rollcall_schools.postal_code")      
        .uniq
        .pluck("rollcall_schools.postal_code") 
      end
    end         
  end
end
