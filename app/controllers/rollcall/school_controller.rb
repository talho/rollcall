class Rollcall::SchoolController < Rollcall::RollcallAppController
  before_filter :rollcall_isd_required

  # GET rollcall/schools
  def index
    results = current_user.school_search params
    respond_to do |format|
      format.json do
        render :json => {
          :success       => true,
          :total_results => results.length,
          :results       => results.as_json
        }
      end
    end
  end

  # POST rollcall/schools
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

  # POST rollcall/get_schools
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

  # POST rollcall/get_school_data
  def get_school_data
    school     = Rollcall::School.find(params[:school_id])
    time_span  = params[:time_span].to_i * 30
    daily_info = school.school_daily_infos
    unless daily_info.blank?
      last_report_date  = Time.parse("#{daily_info.find(:all, :limit => 1, :order => 'report_date DESC').first.report_date}")
      school_daily_info = daily_info.find(:all, :conditions => ["report_date >= ?", last_report_date - time_span.days])
    else
      school_daily_info = []
    end
    respond_to do |format|
      format.json do
        render :json => {
          :success       => true,
          :results       => {:school_daily_infos  => school_daily_info},
          :total_results => school_daily_info.length
        }
      end
    end
  end

  # POST rollcall/get_student_data
  def get_student_data
    school    = Rollcall::School.find(params[:school_id])
    time_span = params[:time_span].to_i * 30
    sdi_init  = Rollcall::StudentDailyInfo.find_by_student_id(school.students, :order => 'report_date DESC')
    unless sdi_init.blank?
      last_report_date   = Time.parse("#{Rollcall::StudentDailyInfo.find_all_by_student_id(school.students, :order => 'report_date DESC', :limit => 1).first.report_date}")
      student_daily_info = Rollcall::StudentDailyInfo.find_all_by_student_id(school.students,:conditions => ["report_date >= ?",last_report_date-time_span.days])
      student_daily_info.each do |r|
        r[:age]    = r.student.dob.blank? ? "Unknown" : (r.report_date.year - r.student.dob.year)
        r[:gender] = r.student.gender.blank? ? "Unknown" : r.student.gender
      end
    else
      student_daily_info = []
    end   
    respond_to do |format|
      format.json do
        render :json => {
          :success       => true,
          :results       => {:student_daily_infos => student_daily_info},
          :total_results => student_daily_info.length
        }
      end
    end
  end
end
