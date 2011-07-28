class Rollcall::SchoolController < Rollcall::RollcallAppController

  def index
    original_included_root = ActiveRecord::Base.include_root_in_json
    ActiveRecord::Base.include_root_in_json = false
    results = Rollcall::School.search(params, current_user)
    respond_to do |format|
      format.json do
        render :json => {
          :success       => true,
          :total_results => results.length,
          :results       => results.as_json
        }
      end
    end
    ActiveRecord::Base.include_root_in_json = original_included_root
  end

  def get_schools_for_combobox
    original_included_root = ActiveRecord::Base.include_root_in_json
    ActiveRecord::Base.include_root_in_json = false
    results = Rollcall::School.find(:all, :select => "id,display_name")
    respond_to do |format|
      format.json do
        render :json => {
          :success       => true,
          :total_results => results.length,
          :results       => results.as_json
        }
      end
    end
    ActiveRecord::Base.include_root_in_json = original_included_root
  end

  def show
    results = Rollcall::School.find_by_id(params[:school_id])
    respond_to do |format|
      format.json do
        render :json => {
          :success => true,
          :results => results.as_json
        }
      end
    end
  end

  def get_schools
    schools = []
    params[:school_ids].split(",").each do |id|
      schools.push(Rollcall::School.find_by_id(id))
    end
    respond_to do |format|
      format.json do
        render :json => {
          :success => true,
          :results => schools.as_json
        }
      end
    end
  end

  def get_school_data
    school             = Rollcall::School.find(params[:school_id])
    time_span          = params[:time_span].to_i * 30
    last_report_date   = Time.parse("#{school.school_daily_infos.find(:all, :limit => 1, :order => 'report_date DESC').first.report_date}")
    school_daily_info  = school.school_daily_infos.find(:all, :conditions => ["report_date >= ?", last_report_date - time_span.days])


    respond_to do |format|
      format.json do
        original_included_root = ActiveRecord::Base.include_root_in_json
        ActiveRecord::Base.include_root_in_json = false
        render :json => {
          :success => true,
          :results => {
            :school_daily_infos  => school_daily_info
          }
        }
        ActiveRecord::Base.include_root_in_json = original_included_root
      end
    end
  end

  def get_student_data
    school             = Rollcall::School.find(params[:school_id])
    time_span          = params[:time_span].to_i * 30
    last_report_date   = Time.parse("#{Rollcall::StudentDailyInfo.find_all_by_student_id(school.students, :order => 'report_date DESC', :limit => 1).first.report_date}")
    #last_report_date   = Time.parse("#{school.school_daily_infos.find(:all, :limit => 1, :order => 'report_date DESC').first.report_date}")
    #student_daily_info = school.student_daily_infos.find(:all,:conditions => ["report_date >= ?", last_report_date - time_span.days])
    student_daily_info = Rollcall::StudentDailyInfo.find_all_by_student_id(school.students,:conditions => ["report_date >= ?",last_report_date-time_span.days])
    student_daily_info.each do |r|
      if r.student.dob.blank?
        r[:age] = "Unknown"
      else
        r[:age] = r.report_date.year - r.student.dob.year
      end
      r[:gender] = r.student.gender.blank? ? "Unknown" : r.student.gender
    end
    respond_to do |format|
      format.json do
        original_included_root = ActiveRecord::Base.include_root_in_json
        ActiveRecord::Base.include_root_in_json = false
        render :json => {
          :success => true,
          :results => {
            :student_daily_infos => student_daily_info
          }
        }
        ActiveRecord::Base.include_root_in_json = original_included_root
      end
    end
  end
end
