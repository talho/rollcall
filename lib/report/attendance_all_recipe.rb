class Report::Rollcall::AttendanceAllRecipe < Report::Recipe
  class << self
    # create_table :report, :force => true do |t|
    #   t.string    :type
    #   t.integer   :author_id
    #
    #   t.timestamps
    # end
    def description
      "Report of Attendance for all schools"
    end

#    def helpers
#      []
#    end

    def template_path
      File.join(Rails.root, 'vendor','plugins','rollcall','app','views', 'reports','attendance_all.html.erb')
    end

    def capture_to_db(report)
      dataset = report.dataset
      i       = 0
      dataset.insert({"created_at"=>Time.now.utc})
      Rollcall::School.all.each do |u|
        u.school_daily_infos.each do |sd|
          doc = Hash["i",i,"display_name",u.display_name,"tea_id",u.tea_id, "total_absent", sd.total_absent,
            "total_enrolled",sd.total_enrolled,"absentee_percentage",sd.absentee_percentage,"severity",sd.severity]
          dataset.insert(doc)
          i += 1
        end
      end
      dataset.create_index("i")
    end
  end
end