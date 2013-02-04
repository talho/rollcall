module Rollcall::DataModule
  def self.included(base)
    base.send(:attr_accessor, :result)
  end
  
  def build_graph_query query, params
    params = param_setup params
    
    query = apply_joins query, params
    query = apply_filters query, params
    query = apply_date_filter query, params[:startdt], params[:enddt]
    query = apply_order query, params
    query = apply_group query, params
    query = apply_selects query, params[:data_func]
        
    query
  end
  
  def transform_to_graph_info_format results
    graph_info = results.as_json
    Jbuilder.encode do |json|
      json.results graph_info      
      if self.is_a? Rollcall::SchoolDistrict
        json.(self, :name)
      else
        json.(self, :tea_id, :gmap_lat, :gmap_lng, :gmap_addr, :school_type)
        json.school_name = self.display_name
        json.school_id = self.id
      end
    end
  end
    
  protected
  
  def apply_joins query, conditions    
    if self.is_a? Rollcall::SchoolDistrict
      query = query.joins("inner join rollcall_schools on rollcall_schools.district_id = rollcall_school_districts.id")   
    end
      
    if @ili      
      query = query.joins("inner join rollcall_students on rollcall_students.school_id = rollcall_schools.id")
                   .joins("inner join rollcall_student_daily_infos on rollcall_student_daily_infos.student_id = rollcall_students.id")
      if self.is_a? Rollcall::School                   
        query = query.joins("left join rollcall_school_daily_infos on rollcall_student_daily_infos.report_date = rollcall_school_daily_infos.report_date and rollcall_schools.id = rollcall_school_daily_infos.school_id")
                     .joins("inner join (select Max(total_enrolled) as max_enrolled, school_id from rollcall_school_daily_infos group by school_id) as max_school_enrollment on max_school_enrollment.school_id = rollcall_schools.id")
      end
      query = query.joins("LEFT JOIN (SELECT SUM(total_enrolled) as total_enrolled, district_id, report_date 
                                 FROM rollcall_schools rs 
                                 JOIN rollcall_school_daily_infos rsdi ON rs.id = rsdi.school_id 
                                 GROUP BY district_id, report_date) district_info on district_info.district_id = rollcall_school_districts.id and district_info.report_date = rollcall_student_daily_infos.report_date") if self.is_a? Rollcall::SchoolDistrict
    else
      query = query.joins("inner join rollcall_school_daily_infos on rollcall_school_daily_infos.school_id = rollcall_schools.id")
                   .joins("inner join (select Max(total_enrolled) as max_enrolled, school_id from rollcall_school_daily_infos group by school_id) as max_school_enrollment on max_school_enrollment.school_id = rollcall_schools.id")
    end
    
    query
  end
  
  def apply_filters query, conditions
    return query unless @ili #short circuit this method
    
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
    if @ili           
      report_date = "rollcall_student_daily_infos.report_date"
    else
      report_date = "rollcall_school_daily_infos.report_date"
    end
    
    if start_date.present? and end_date.present?
      query = query.where("#{report_date} between ? and ? ", start_date, end_date)
    elsif start_date.present?
      query = query.where("#{report_date} >= ?", start_date)
    elsif end_date.present?
      query = query.where("#{report_date} <= ?", end_date)
    end
    
    query    
  end
  
  def apply_order query, conditions
    if @ili
      query = query.order("rollcall_student_daily_infos.report_date")
    elsif
      query = query.order("rollcall_school_daily_infos.report_date")
    end
    
    query
  end
  
  def apply_group query, conditions
    if @ili
      query = query.group("rollcall_student_daily_infos.report_date")
      query = query.group("rollcall_schools.district_id") if self.is_a?(Rollcall::SchoolDistrict)
    elsif self.is_a?(Rollcall::SchoolDistrict)
      query = query.group("rollcall_schools.district_id, rollcall_school_daily_infos.report_date")
    end
    
    query
  end
  
  def apply_selects query, function    
    if @ili           
      total_absent = "count(*)"
      report_date = "rollcall_student_daily_infos.report_date"
      total_enrolled = self.is_a?(Rollcall::School) ? "MAX(CASE WHEN total_enrolled = 0 or total_enrolled is null THEN max_enrolled ELSE total_enrolled END)" : "MAX(district_info.total_enrolled)"
    elsif self.is_a?(Rollcall::School)
      total_absent = "total_absent"  
      report_date = "rollcall_school_daily_infos.report_date"      
      total_enrolled = "CASE WHEN total_enrolled = 0 or total_enrolled is null THEN max_enrolled ELSE total_enrolled END"
    elsif self.is_a?(Rollcall::SchoolDistrict)
      total_absent = "SUM(total_absent)"
      report_date = "rollcall_school_daily_infos.report_date"
      total_enrolled = "SUM(total_enrolled)"
    end
    
    function = [function] unless function.is_a?(Array)
    query = query.select("stddev_pop(#{total_absent}) over (order by #{report_date} asc rows between unbounded preceding and current row) as \"deviation\"") if function.include?("Standard Deviation")       
    query = query.select("avg(#{total_absent}) over (order by #{report_date} asc rows between unbounded preceding and current row) as \"average\"") if function.include?("Average")
    query = query.select("avg(#{total_absent}) over (order by #{report_date} asc rows between 29 preceding and current row) as \"average\"") if function.include?("Average 30 Day")
    query = query.select("avg(#{total_absent}) over (order by #{report_date} asc rows between 59 preceding and current row) as \"average\"") if function.include?("Average 60 Day")
    if function.include?("Cusum")
      avg = (query.select("AVG(#{total_absent}) OVER () as av").limit(1).first || {"av" => 0})["av"].to_f
      query = query.select("greatest(sum(#{total_absent} - #{avg}) over (order by #{report_date} rows between unbounded preceding and current row),0) as \"cusum\"")
    end
    
    query = query.select("#{report_date} as report_date")
      .select(%{#{total_absent} as "total", #{total_enrolled} as "enrolled"})  
    query
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
    
    @ili = (params[:age].present? || params[:gender].present? || params[:grade].present? || params[:confirmed_illness] == true || params[:symptoms].present?)
    
    return params
  end
      
  def get_search_results params
    if params[:return_individual_school].blank?
      school_ids = current_user
        .school_search_relation(params)
        .where('rollcall_schools.district_id is not null')
        .reorder('rollcall_schools.district_id')
        .pluck('rollcall_schools.district_id')
        .uniq
      results = current_user.school_districts.where("rollcall_school_districts.id in (?)", school_ids)
    else
      results = current_user.school_search params
    end
    
    results
  end   

end
