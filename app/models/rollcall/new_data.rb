class Rollcall::NewData
  def self.export_data params, filename, user_obj
    
  end
  
  def self.get_graph_data params, obj
    conditions = set_conditions params
    update_ary = []
    i = obj    
       
    if i.is_a? Rollcall::SchoolDistrict      
      results = Rollcall::SchoolDistrict        
        .where('rollcall_school_districts.id = ?', i[:id])           
    elsif i.is_a? Rollcall::School
      results = Rollcall::School
        .where('rollcall_schools.id = ?', i[:id])
    else
      raise TypeError, "Expected obj to be a Rollcall::School or Rollcall::SchoolDistrict"
    end
        
    results = join_to_infos results, conditions
    results = apply_date_filter results, conditions[:startdt], conditions[:enddt]
    results = 
    results = apply_data_function results, conditions[:data_func]
  end
  
  def join_to_infos query, conditions
    if conditions[:age].present? || conditions[:gender].present? || conditions[:grade].present? || conditions[:confirmed_illness] == true || conditions[:symptoms].present?      
      query = apply_ili_filters query, conditions
    else
      if results.table_name = "rollcall_school_districts"
        query = query
          .joins("inner join rollcall_school_district_daily_infos on rollcall_school_district_daily_infos.school_district_id = rollcall_school_districts.id")
      else
        query = query
          .joins("inner join rollcall_school_daily_infos on rollcall_school_daily_infos.school_id = rollcall_schools.id")
      end
    end
    query
  end
  
  def apply_ili_filters query, conidtions       
    if query.table_name = "rollcall_school_districts"
      query = query
        .joins("inner join rollcall_schools on rollcall_schools.district_id = rollcall_school_districts.id")          
    end
    
    query = query
      .joins("inner join rollcall_students on rollcall_students.school_id on rollcall_schools.id")
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
        .where("rollcall_symptoms.symptoms in (?)", conditions)
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
  
  def apply_data_function query, function, info_type
    case options[:data_func]
      when "Standard Deviation"
        query = query.select('stddev_pop(total_absent) as "deviation"')
      when "Average"
        query = query.select('avg(total_absent) over (order by report date) as "average"')
      when "Average 30 Day"
        query = query.select('avg(total_absent) over (order by report date rows between current row and 29 preceeding) as "average"')
      when "Average 60 Day"
        query = query.select('avg(total_absent) over (order by report date rows between current row and 59 preceeding) as "average"')
      when "Cusum"
        avg = info_type.average('total_absent').to_f
        query = query.select('greatest(greatest(sum((id - ?)) over (order by created_at rows between unbounded preceding and 1 preceding),0) + id - ?,0)', avg)
    end
    query
  end
  
  def self.set_conditions options
    conditions = {}
    options.each { |key,value|
      case key
        when "data_func"
          conditions[:data_func] = value
        when "absent"
          conditions[:confirmed_illness] = true if value == "Confirmed Illness"
        when "gender"
          conditions[:gender] = 'M' if value == "Male"
          conditions[:gender] = 'F' if value == "Female"
        when "age"
          conditions[:age] = value.collect{|v| v.to_i}
        when "grade"
          conditions[:grade] = value.collect{|v| v.to_i}
        when "symptoms"
          conditions[:symptoms] = value
        when "startdt"
          conditions[:startdt] = value
        when "enddt"
          conditions[:enddt] = value
        else
      end
    }
    return conditions
  end    
  
  def self.build_csv_string data_obj
    
  end
end