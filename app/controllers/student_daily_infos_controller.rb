class StudentDailyInfosController < ApplicationController
  respond_to :html

  def index
    @student_daily_infos = StudentDailyInfo.includes(:symptoms, :student => {:school => [:school_district]}).references(:students, :schools).joins("
      LEFT JOIN school_users ON schools.id = school_users.school_id
      LEFT JOIN school_district_users ON schools.school_district_id = school_district_users.school_district_id
    ").where("school_users.user_id = :user_id OR school_district_users.user_id = :user_id", {user_id: current_user.id}).order(date_of_onset: :desc).distinct

    respond_with @student_daily_infos
  end

  def new
    @student_daily_info = StudentDailyInfo.new(student: Student.new)

    @schools = School.for_user(current_user).order(:name)
    @symptoms = Symptom.order(:name)

    respond_with @student_daily_info
  end

  def create
    @student_daily_info = StudentDailyInfo.new
    @student_daily_info.student = Student.where(student_attributes_params[:student_attributes]).first_or_initialize

    authorize! :manage, @student_daily_info

    @student_daily_info.attributes = student_daily_info_params
    @student_daily_info.attributes = student_reported_symptoms_attributes_params

    @student_daily_info.save

    loc = @student_daily_info.errors.blank? ? student_daily_infos_path : new_student_daily_info_path
    respond_with @student_daily_info, location: loc
  end

  def edit
    @student_daily_info = StudentDailyInfo.includes(:symptoms, :student => {:school => [:school_district]}).find(params[:id])
    authorize! :manage, @student_daily_info

    @schools = School.for_user(current_user).order(:name)
    @symptoms = Symptom.order(:name)

    respond_with @student_daily_info
  end

  def update
    @student_daily_info = StudentDailyInfo.includes(:symptoms, :student => {:school => [:school_district]}).find(params[:id])
    @student_daily_info.student = Student.where(student_attributes_params[:student_attributes]).first_or_initialize
    authorize! :manage, @student_daily_info

    @student_daily_info.attributes = student_daily_info_params
    new_srs = student_reported_symptoms_attributes_params[:student_reported_symptoms_attributes].map{|srs| srs[:symptom_id]}
    @student_daily_info.student_reported_symptoms.reject{|srs| new_srs.include?(srs.symptom_id) }.each{|srs| srs.mark_for_destruction }
    @student_daily_info.attributes = student_reported_symptoms_attributes_params

    @student_daily_info.save

    loc = @student_daily_info.errors.blank? ? student_daily_infos_path : edit_student_daily_info_path(@student_daily_info)
    respond_with @student_daily_info, location: loc
  end

  def destroy
    @student_daily_info = StudentDailyInfo.includes(:symptoms, :student => {:school => [:school_district]}).find(params[:id])
    authorize! :manage, @student_daily_info
    @student_daily_info.destroy

    respond_with @student_daily_info
  end

  protected
  def student_daily_info_params
    params.require(:student_daily_info).permit(:report_date, :grade, :confirmed_illness)
  end

  def student_attributes_params
    params.require(:student_daily_info).permit(:student_attributes => [:student_number, :school_id])
  end

  def student_reported_symptoms_attributes_params
    {student_reported_symptoms_attributes: params.require(:student_daily_info).require(:student_reported_symptom).permit![:symptom_id].reject(&:blank?).map{|sid| {symptom_id: sid}}}
  end
end
