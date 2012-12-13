class Rollcall::GraphingResults
  def export_data(options_hash)
    user_obj = User.find(options_hash[:user_id]) 
    filename = "rollcall_export.#{Time.now.strftime("%m-%d-%Y")}"
    params = options_hash[:params]
    
    if params[:return_individual_school].blank?
      school_ids = user_obj
        .school_search_relation(params)
        .where('rollcall_schools.district_id is not null')
        .reorder('rollcall_schools.district_id')
        .pluck('rollcall_schools.district_id')
        .uniq
      results = user_obj.school_districts.where("rollcall_school_districts.id in (?)", school_ids)
    else
      results = user_obj.school_search params
    end
    
    results.each do |r|      
      r.result = r.get_graph_data(params).as_json
    end    
    
    if results.first.is_a? Rollcall::SchoolDistrict
      @csv_data = "District Name,Identifier,Total Absent,Total Enrolled,Report Date\n"
    else
      @csv_data = "School Name,Identifier,Total Absent,Total Enrolled,Report Date\n"
    end
    
    results.each do |row|
      row.result.each do |r|
        if results.first.is_a? Rollcall::SchoolDistrict
          @csv_data += "#{row.name},#{r["total"]},#{r["enrolled"]},#{r["report_date"]}\n"
        else          
          @csv_data += "#{row.display_name},#{row.tea_id},#{r["total"]},#{r["enrolled"]},#{r["report_date"]}\n"
        end             
      end
    end
    
    newfile            = File.join(Rails.root.to_s,'tmp',"#{filename}.csv")
    file_result        = File.open(newfile, 'wb') {|f| f.write(@csv_data) }
    file               = File.new(newfile, "r")
    folder             = Folder.find_by_name_and_user_id("Rollcall Documents", user_obj.id)
    folder             = Folder.create(
      :name => "Rollcall Documents",
      :notify_of_document_addition => true,
      :owner => user_obj) if folder.blank?
    @document = user_obj.documents.build(:folder_id => folder.id, :file => file)    
    @document.save!
    if !@document.folder.nil? && @document.folder.notify_of_document_addition
      DocumentMailer.rollcall_document_addition(@document, user_obj).deliver
    end    
    true
  end
  
  handle_asynchronously :export_data
end