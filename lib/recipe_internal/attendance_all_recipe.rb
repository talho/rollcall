=begin
AttendanceAllRecipe produces report detailing current total absent data for each school
=end
class RecipeInternal::AttendanceAllRecipe < RecipeInternal

  class << self
    def description
      "Report of Attendance for all schools"
    end

    def current_user
      @current_user
    end

    def template_path
      File.join(Rails.root, 'vendor','plugins','rollcall','app','views', 'reports','attendance_all.html.erb')
    end

    def template_directives
      [['display_name','School Name'],['tea_id','TEA ID'],['total_absent','Total Absent'],['total_enrolled', 'Total Enrolled'],
       ['absentee_percentage','Absentee Rate'],['severity','Absentee Severity']]
    end

    def layout_path
      File.join(Rails.root, 'vendor','plugins','rollcall','app','views', 'reports','layout.html.erb')
    end
    
    def capture_to_db(report)
      @current_user = report.author
      dataset       = report.dataset
      i             = 0
      dataset.insert({:report=>{:created_at=>Time.now.utc}})
      dataset.insert({:meta=>{:template_directives=>template_directives}}.as_json )
      unless report.criteria[:school_id].blank?
        school_set = Rollcall::School.find_all_by_id(report.criteria[:school_id])
      else
        school_set = @current_user.schools
      end
      school_set.each do |u|
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