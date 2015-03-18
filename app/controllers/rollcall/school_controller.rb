class Rollcall::SchoolController < Rollcall::RollcallAppController
  before_filter :rollcall_isd_required
  respond_to :json
  layout false

  # GET rollcall/schools
  def index
    @results = current_user.school_search params
    respond_with(@result)
  end

  # GET rollcall/schools/:id
  def show
    @results = Rollcall::School.find_by_id(params[:school_id])
    respond_with(@results)
  end

  # GET rollcall/get_schools
  def get_schools
    @schools = Rollcall::School.where('id in (?)', params[:school_ids])
    respond_with(@schools)
  end

  # GET rollcall/get_school_data
  def get_school_data
    time_span  = params[:time_span].to_i * 30
    @info = Rollcall::SchoolDailyInfo.where('school_id = ? AND report_date >= ?', params[:school_id], time_span.days.ago).order('report_date DESC')
    respond_with(@info)
  end

  # GET rollcall/get_student_data
  def get_student_data
    time_span = params[:time_span].to_i * 30
    @info = Rollcall::StudentDailyInfo.select("rollcall_student_daily_infos.*, coalesce(cast(extract(year from age(rollcall_students.dob)) as text), 'Unkown') as age, coalesce(rollcall_students.gender, 'Unknown') as gender")
                .joins('JOIN rollcall_students on rollcall_student_daily_infos.student_id = rollcall_students.id')
                .where("rollcall_students.school_id = ? AND report_date >= ?", params[:school_id], time_span.days.ago)
                .order('report_date DESC')
    respond_with(@info)
  end
end
