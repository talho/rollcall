=begin
IliAllRecipe will produce report to detailing student ili information for a given school
=end
class RecipeInternal::IliAllRecipe < RecipeInternal


  class << self
    def description
      "Report of ILI for all schools"
    end

    def current_user
      @current_user
    end

    def template_path
      File.join(Rails.root, 'vendor','plugins','rollcall','app','views', 'reports','ili_all.html.erb')
    end

    def template_directives
      [['display_name','School Name'],['tea_id','TEA ID'],['student_first_name','First Name'],['student_last_name', 'Last Name'],
       ['symptoms','Symptoms'],['report_date','Report Date']]
    end

    def layout_path
      File.join(Rails.root, 'vendor','plugins','rollcall','app','views', 'reports','layout.html.erb')
    end

    def capture_to_db(report)
      @current_user = report.author
      dataset       = report.dataset
      i             = 0
      id            = {:report_id => report.id}
      dataset.insert( id.merge( {:report=>{:created_at=>Time.now.utc}}))
      dataset.insert( id.merge( {:meta=>{:template_directives=>template_directives}}.as_json ))
      unless report.criteria[:school_id].blank?
        school_set = Rollcall::School.find_all_by_id(report.criteria[:school_id])
      else
        school_set = @current_user.schools
      end
      school_set.each do |u|
        u.students.each do |s|
          s.student_daily_info.each do |st|
            symptoms = st.student_reported_symptoms.map(&:symptom).map(&:name).join(",")
            doc      = Hash["i",i, "display_name",u.display_name,"tea_id",u.tea_id,"student_first_name",s.first_name,
              "student_last_name",s.last_name,"symptoms",symptoms,"report_date",st.report_date.to_time.utc]
            dataset.insert(doc.merge(id))
            i += 1
          end
        end
      end
      dataset.create_index("i")
    end
  end
end