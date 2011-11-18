class Report::Rollcall::IliAllRecipe < Report::Recipe
  class << self
    # create_table :report, :force => true do |t|
    #   t.string    :type
    #   t.integer   :author_id
    #
    #   t.timestamps
    # end

    def description
      "Report of ILI for all schools"
    end

    def template_path
      File.join(Rails.root, 'vendor','plugins','rollcall','app','views', 'reports','ili_all.html.erb')
    end

    def capture_to_db(report)
      dataset = report.dataset
      i       = 0
      dataset.insert({"created_at"=>Time.now.utc})
      Rollcall::School.all.each_with_index do |u|
        u.students.each_with_index do |s, c|
          s.student_daily_info.each do |st|
            symptoms = st.student_reported_symptoms.map(&:symptom).join(",")
            doc      = Hash["i",i, "display_name",u.display_name,"tea_id",u.tea_id,"student_first_name",s.first_name,
              "student_last_name",s.last_name,"symptoms",symptoms,"report_date",st.report_date]
            dataset.insert(doc)
            i += 1
          end
        end
      end
      dataset.create_index("i")
    end
  end
end