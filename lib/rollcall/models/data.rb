module Rollcall
  module Models
    module Data
      def export_data params, filename, user_obj, obj
        update_array = obj.map do |row|
          array = transform_to_graph_info_format(build_graph_query(params, row), row)
        end
        
        @csv_data = build_csv_string update_array
        newfile            = File.join(Rails.root.to_s,'tmp',"#{filename}.csv")
        file_result        = File.open(newfile, 'wb') {|f| f.write(@csv_data) }
        file               = File.new(newfile, "r")
        folder             = Folder.find_by_name_and_user_id("Rollcall Documents", user_obj.id)
        folder             = Folder.create(
          :name => "Rollcall Documents",
          :notify_of_document_addition => true,
          :owner => user_obj) if folder.blank?
        folder.audience.recipients(:force => true).length if folder.audience
        @document = user_obj.documents.build(:folder_id => folder.id, :file => file)
        @document.save!
        if !@document.folder.nil? && @document.folder.notify_of_document_addition
          DocumentMailer.rollcall_document_addition(@document, user_obj).deliver
        end
        return true
      rescue => e
        p e.message
        e.backtrace.each do |msg|
          p msg + '\n'
        end
      end
      
      def build_graph_query query, params
        params = param_setup params
        
        query = join_to_infos query, params
        query = apply_date_filter query, params[:startdt], params[:enddt]
        query = apply_data_function query, params[:data_func]
        
        query
      end
      
      def self.transform_to_graph_info_format results, obj    
        graph_info = ActiveRecord::Base.connection().execute(results.order("report_date").to_sql)
        graph_info = graph_info.as_json
        if obj.is_a? Rollcall::SchoolDistrict
          if graph_info.first.present?
            graph_info.first[:name] = obj.name
          else
            graph_info = [{:name => obj.name}]
          end
        else
          if graph_info.first.present?      
            graph_info.first[:tea_id] = obj.tea_id
            graph_info.first[:school_name] = obj.display_name
            graph_info.first[:school_id] = obj.id        
            graph_info.first[:gmap_lat] = obj.gmap_lat
            graph_info.first[:gmap_lng] = obj.gmap_lng
            graph_info.first[:gmap_addr] = obj.gmap_addr
          else
            graph_info = [{
              :school_name => obj.display_name,
              :tea_id      => obj.tea_id,
              :school_id   => obj.id,
              :gmap_lat    => obj.gmap_lat,
              :gmap_lng    => obj.gmap_lng,
              :gmap_addr   => obj.gmap_addr
            }]
          end
        end
        graph_info
      end
        
      protected
      
      def join_to_infos query, conditions      
        if conditions[:age].present? || conditions[:gender].present? || conditions[:grade].present? || conditions[:confirmed_illness] == true || conditions[:symptoms].present?      
          query = apply_ili_filters query, conditions
        else
          if query.table_name == "rollcall_school_districts"
            query = query
              .joins("inner join rollcall_school_district_daily_infos on rollcall_school_district_daily_infos.school_district_id = rollcall_school_districts.id")
          else
            query = query
              .joins("inner join rollcall_school_daily_infos on rollcall_school_daily_infos.school_id = rollcall_schools.id")
          end
        end
        
        query
      end
      
      def apply_ili_filters query, conditions       
        if query.table_name == "rollcall_school_districts"
          query = query
            .joins("inner join rollcall_schools on rollcall_schools.district_id = rollcall_school_districts.id")          
        end
        
        query = query
          .joins("inner join rollcall_students on rollcall_students.school_id = rollcall_schools.id")
          .joins("inner join rollcall_student_daily_infos on rollcall_student_daily_infos.student_id = rollcall_students.id")
        
        if conditions[:age].present?        
          query = query.where("extract(year from age(rollcall_students.dob)) in (?)", conditions[:age])                    
        end
        
        if conditions[:gender].present?
          query = query.where("rollcall_students.gender = ?", conditions[:gender])
        end
        
        if conditions[:grade].present?
          query = query.where("rollcall_student_daily_infos.grade in (?)", conditions[:grade])
        end
              
        if conditions[:confirmed_illness] == true
          query = query.where("rollcall_student_daily_infos.confirmed_illness = true")
        end
        
        if conditions[:symptoms].present?
          query = query
            .joins("inner join rollcall_student_reported_symptoms on rollcall_student_reported_symptoms.student_daily_info_id = rollcall_student_daily_infos.id")
            .joins("inner join rollcall_symptoms on rollcall_symptoms.id = rollcall_student_reported_symptoms.symptom_id")
            .where("rollcall_symptoms.icd9_code in (?)", conditions[:symptoms])
        end
        
        query
      end
      
      def apply_date_filter query, start_date, end_date
        if start_date.present? and end_date.present?
          query = query.where("report_date between ? and ? ", start_date, end_date)
        elsif start_date.present?
          query = query.where("report_date >= ?", start_date)
        elsif end_date.present?
          query = query.where("report_date <= ?", end_date)
        end
        
        query    
      end
      
      def apply_data_function query, function
        info_type = get_info_type_class query
        
        if info_type == Rollcall::SchoolDailyInfo || info_type == Rollcall::SchoolDistrictDailyInfo       
          total_absent = "total_absent"      
        else
          total_absent = "count(*)"
          query = query.group("report_date")
        end
        
        case function
          when "Standard Deviation"
            query = query.select("stddev_pop(#{total_absent}) over (order by report_date asc rows between unbounded preceding and current row) as \"deviation\"")        
          when "Average"
            query = query.select("avg(#{total_absent}) over (order by report_date asc rows between unbounded preceding and current row) as \"average\"")
          when "Average 30 Day"
            query = query.select("avg(#{total_absent}) over (order by report_date asc rows between 29 preceding and current row) as \"average\"")
          when "Average 60 Day"
            query = query.select("avg(#{total_absent}) over (order by report_date asc rows between 59 preceding and current row) as \"average\"")
          when "Cusum"
            avg = info_type.average("#{total_absent}").to_f
            query = query.select("greatest(greatest(sum((#{total_absent} - #{avg})) over (order by report_date rows between unbounded preceding and 1 preceding),0) + #{total_absent} - #{avg},0) as \"cusum\"")
        end
        
        query = query.select("to_char(report_date, 'MM-DD-YY') as report_date")
          .select("#{total_absent} as \"total\"")  
        query
      end
      
      def get_info_type_class query
        info_type = ""
              
        query.join_sources.each do |source|      
          source.left.scan(/ [\w|_]*_infos /) do |match|
            info_type = match.strip
          end
        end
        
        case info_type
          when "rollcall_school_daily_infos"
            type = Rollcall::SchoolDailyInfo
          when "rollcall_school_district_daily_infos"
            type = Rollcall::SchoolDistrictDailyInfo
          when "rollcall_student_daily_infos"
            type = Rollcall::StudentDailyInfo
        end
        
        type
      end
          
        
      def param_setup params
        params = params.with_indifferent_access
        
        if params[:gender].present?
          if params[:gender] == "Male"
            params[:gender] = 'M'
          else
            params[:gender] = 'F'
          end
        end
        
        if params[:absent].present? && params[:absent] == "Confirmed Illness"
          params[:confirmed_illness] = true
        end
        
        return params
      end    
      
      def build_csv_string data_obj
        csv_data = "Name,Identifier,Total Absent,Total Enrolled,Report Date\n"
        
        data_obj.each do |row|
          if row["total"].to_s != "0"
            csv_data += "#{row[:school_name]},#{row[:tea_id]},#{row[:total]},#{row[:enrolled]},#{row[:report_date]}\n"
          end
        end
        
        csv_data
      end
    end
  end
end