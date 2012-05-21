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
      File.join(File.dirname(__FILE__),'..','..','views', 'reports','ili_all.html.erb')
    end

    def template_directives
      [['display_name','School Name'],['tea_id','TEA ID'],['student_first_name','First Name'],['student_last_name', 'Last Name'],
       ['symptoms','Symptoms'],['report_date','Report Date']]
    end

    def layout_path
      File.join(File.dirname(__FILE__),'..','..','views', 'reports','layout.html.erb')
    end

    def capture_to_db(report)
      @current_user = report.author
      dataset       = report.dataset
<<<<<<< HEAD:app/models/recipe_internal/ili_all_recipe.rb
=======
      i             = 0
>>>>>>> 4ddac79d96de49953253cffa24d5fbd517261b0e:lib/recipe_internal/ili_all_recipe.rb
      id            = {:report_id => report.id}
      dataset.insert( id.merge( {:report=>{:created_at=>Time.now.utc}}))
      dataset.insert( id.merge( {:meta=>{:template_directives=>template_directives}}.as_json ))
      unless report.criteria[:school_id].blank?
        school_set = Rollcall::School.find_all_by_id(report.criteria[:school_id])
      else
        school_set = @current_user.schools
      end
      index =0
      school_set.each do |u|
        u.students.each do |s|
          s.student_daily_info.each do |st|
            symptoms = st.student_reported_symptoms.map(&:symptom).map(&:name).join(",")
<<<<<<< HEAD:app/models/recipe_internal/ili_all_recipe.rb
            begin
              doc = id.clone
              doc[:display_name] = u.display_name
              doc[:tea_id] = u.tea_id
              doc[:student_first_name] = s.first_name
              doc[:student_last_name] = s.last_name
              doc[:symptoms] = symptoms
              doc[:report_date] = st.report_date.to_time.utc
              doc[:i] = index += 1
              dataset.insert(doc)
            rescue NoMethodError => error
              # skip this illegitimate attempt
            end
=======
            doc      = Hash["i",i, "display_name",u.display_name,"tea_id",u.tea_id,"student_first_name",s.first_name,
              "student_last_name",s.last_name,"symptoms",symptoms,"report_date",st.report_date.to_time.utc]
            dataset.insert(doc.merge(id))
            i += 1
>>>>>>> 4ddac79d96de49953253cffa24d5fbd517261b0e:lib/recipe_internal/ili_all_recipe.rb
          end
        end
      end
      dataset.create_index("i")
    end
  end
end