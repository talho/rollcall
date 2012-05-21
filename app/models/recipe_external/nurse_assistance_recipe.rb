=begin
NurseAssitanceRecipe will gather up all schools attached to the author(user) and report how many ILI cases each school
is reporting
=end
class RecipeExternal::NurseAssistanceRecipe < RecipeExternal

  class << self

    def description
      "Report of Schools Sending ILI Data"
    end

    def current_user
      @current_user
    end

    def template_path
      File.join(File.dirname(__FILE__),'..','..','views', 'reports','nurse_assistance.html.erb')
    end

    def template_directives
      [['display_name','School Name'],['tea_id','TEA ID'],['total_students','Total Reported Students'],['total_symptoms','Total Reported Symptoms']]
    end

    def layout_path
      File.join(File.dirname(__FILE__),'..','..','views', 'reports','layout.html.erb')
    end

    def capture_to_db(report)
      @current_user     = report.author
      dataset           = report.dataset
      school_set        = @current_user.schools
      report_school_set = []
      id                = {:report_id => report.id}
      dataset.insert( id.merge( {:report=>{:created_at=>Time.now.utc}} ))
      dataset.insert( id.merge( {:meta=>{:template_directives=>template_directives}}.as_json ))
      school_set.each do |s|
        unless s.students.blank?
          symp_list_count = 0
          s.students.each do |st|
            st.student_daily_info.each do |sdi|
              symp_list_count += sdi.student_reported_symptoms.map(&:symptom).length
            end
          end
          report_school_set.push([s.display_name, s.tea_id, s.students.length, symp_list_count])
        end
      end
      index = 0
      report_school_set.each do |r|
        begin
          doc = id.clone
          doc[:display_name] = r[0]
          doc[:tea_id] = r[1]
          doc[:total_students] = r[2]
          doc[:total_symptoms] = r[3]
          doc[:i] = index += 1
          dataset.insert(doc)
        rescue NoMethodError => error
          # skip this illegitimate attempt
        end
      end
      dataset.create_index("i")
    end
  end
end