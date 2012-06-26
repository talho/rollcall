When /^I school search with:$/ do |table|
  params = Hash.new
  table.raw.each do |row|
    case row[0].to_s
      when "District"
        params[:school_district] = row[1].to_s
      when "Zip"
        params[:zip] = row[1].to_s
      when "Name"
        params[:school] = row[1].to_s
      when "Type"
        params[:school_type] = row[1].to_s
    end
  end
  
  user = User.find_by_email('nurse.betty@example.com')
  @schools = user.school_search params
end

Then /^I (should not )?find the school ids:$/ do |should, table|
  table.raw.each do |row|
    flag = false    
    @schools.each do |school|      
      if school.school_number.to_s == row[0].to_s
        flag = true
      end  
    end
    if !should
      assert flag, "School number #{row[0]} does not appear"
    else
      assert !flag, "School number #{row[0]} does appear and shouldn't"
    end
  end
end