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

  # Create student daily infos by array. Look up matches for symptoms.
  def batch
    @student_daily_infos = params[:student_daily_infos].map do |sdi|
      sdi = ActionController::Parameters.new(sdi)
      if sdi[:student_attributes][:school_id].blank?
        school = School.where(school_id: sdi[:student_attributes][:school_state_id]).first
        next if school.blank?
        sdi[:student_attributes][:school_id] = school.id
      end

      student_daily_info = StudentDailyInfo.new
      student_daily_info.student = Student.where(student_attributes_attrs(sdi)).first_or_initialize

      next if cannot? :manage, student_daily_info

      student_daily_info.attributes = student_daily_info_attrs(sdi)

      symptoms = sdi[:symptoms].map do |s|
        symptom = Symptom.joins(:symptom_tags).where("? LIKE '%'||match||'%'", s).first
        symptom.blank? ? nil : {symptom_id: symptom.id}
      end.compact.uniq
      student_daily_info.attributes = {student_reported_symptoms_attributes: symptoms}

      student_daily_info.save
      student_daily_info
    end

    render json: @student_daily_infos
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
    student_daily_info_attrs params.require(:student_daily_info)
  end

  def student_daily_info_attrs(p)
    p.permit(:report_date, :grade, :confirmed_illness)
  end

  def student_attributes_params
    student_attributes_attrs params.require(:student_daily_info)
  end

  def student_attributes_attrs(p)
    p.permit(:student_attributes => [:student_number, :school_id])
  end

  def student_reported_symptoms_attributes_params
    {student_reported_symptoms_attributes: params.require(:student_daily_info).require(:student_reported_symptom).permit![:symptom_id].reject(&:blank?).map{|sid| {symptom_id: sid}}}
  end
end
