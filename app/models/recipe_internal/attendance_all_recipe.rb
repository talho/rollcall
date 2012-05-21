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
      File.join(File.dirname(__FILE__),'..','..','views','reports','attendance_all.html.erb')
    end

    def template_directives
      [['display_name','School Name'],['tea_id','TEA ID'],['total_absent','Total Absent'],['total_enrolled', 'Total Enrolled'],
       ['absentee_percentage','Absentee Rate'],['severity','Absentee Severity']]
    end

    def layout_path
      File.join(File.dirname(__FILE__),'..','..','views','reports','layout.html.erb')
    end

    def capture_to_db(report)
      @current_user = report.author
      dataset       = report.dataset
      id            = {:report_id => report.id}
      dataset.insert( id.merge( {:report=>{:created_at=>Time.now.utc}} ))
      dataset.insert( id.merge( {:meta=>{:template_directives=>template_directives}}.as_json ))
      unless report.criteria[:school_id].blank?
        school_set = Rollcall::School.find_all_by_id(report.criteria[:school_id])
      else
        school_set = @current_user.schools
      end
      index = 0
      school_set.each do |u|
        u.school_daily_infos.each do |sd|
          begin
            doc = id.clone
            doc[:display_name]= u.display_name
            doc[:tea_id] = u.tea_id
            doc[:total_absent] = sd.total_absent
            doc[:total_enrolled] = sd.total_enrolled
            doc[:absentee_percentage] = sd.absentee_percentage
            doc[:severity] = sd.severity
            doc[:i] = index += 1
            dataset.insert(doc)
          rescue NoMethodError => error
            # skip this illegitimate attempt
          end
        end
      end
      dataset.create_index("i")
    end
  end
end