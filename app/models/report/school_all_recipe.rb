class Report::SchoolAllRecipe < Report::Recipe

  # create_table :report, :force => true do |t|
  #   t.string    :type
  #   t.integer   :author_id
  #
  #   t.timestamps
  # end

  def description
    "Report of all schools with their display_name, postal code, school number and tea_id columns"
  end

  def template_path
    File.join(File.dirname(__FILE__), '..','..','views', 'reports','school_all.html.erb')
  end

  def capture_to_db(report)
    dataset = report.dataset
    dataset.insert({"created_at"=>Time.now.utc})
    Rollcall::School.all.each_with_index do |u,i|
      doc = Hash["i",i,"display_name",u.display_name,"postal_code",u.postal_code,"school_number",u.school_number,"tea_id",u.tea_id]
      dataset.insert(doc)
    end
    dataset.create_index("i")
  end

end


