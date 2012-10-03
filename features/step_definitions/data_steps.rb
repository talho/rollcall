include Rollcall::DataModule

When /^I do get_data for "([^\"]*)" with:$/ do |lookup, table|
  @params = Hash.new
  table.raw.each do |row|
    case row[0].to_s
      when "data_func"
        @params["data_func"] = row[1]
      when "absent"
        @params["absent"] = row[1]
      when "gender"
        @params["gender"] = row[1]
      when "age"
        @params["age"] = [row[1]]
      when "grade"
        @params["grade"] = [row[1]]
      when "symptoms"
        @params["symptoms"] = [row[1]]
      when "startdt"
        @params["startdt"] = DateTime.parse(row[1]).strftime("%Y-%m-%d")
      when "enddt"
        @params["enddt"] = DateTime.parse(row[1]).strftime("%Y-%m-%d")
    end
  end
  
  loc = Rollcall::SchoolDistrict.find_by_name(lookup)
  if loc == nil
    loc = Rollcall::School.find_by_display_name(lookup)
  end    
     
  @result = loc.get_graph_data(@params).order("report_date").as_json
end

Then /^get_data should return:$/ do |table|    
   test = hashify(table) 
   data = normalize(@result)
   #old_data = normalize(@old_result)
   
   if test != data
     p "Input: "
     p test
     p "Results: "
     p data
     # p "Old Results: "
     # p old_data
   end   

   test.should eq data 
end

def normalize array
  return_array = Array.new
  array.each do |hash|
    return_hash = Hash.new
    hash.each do |key, value|           
      case key.to_s
        when "total"
          return_hash[:total] = value          
        when "report_date"
          return_hash[:report_date] = value
        when "deviation"
          return_hash[:func] = value.to_f.round(3)
        when "average"
          return_hash[:func] = value.to_f.round(3)
        when "cusum"
          return_hash[:func] = value.to_f.round(3)
      end            
    end
    return_array.push(return_hash)
  end
  
  return_array.sort_by{ |a| a[:report_date] }
end

def hashify table
  return_array = Array.new
  
  table.raw.each do |row|
    return_hash = Hash.new
    
    return_hash[:func] = row[2].to_f.round(3) if row.count > 2
    return_hash[:report_date] =  Date.parse(row[1]).strftime("%Y-%m-%d")
    return_hash[:total] = row[0]
                
    return_array.push(return_hash)
  end
  
  return_array.sort_by{ |a| a[:report_date] }
end