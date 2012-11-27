class Rollcall::StudentController < Rollcall::RollcallAppController
  before_filter :rollcall_student_required
  respond_to :json
  layout false
  
  # GET rollcall/students
  def index
    options = {:page => (params[:start].to_i / (params[:limit] || 25).to_i) + 1, :per_page => (params[:limit] || 25).to_i}
    students = Rollcall::Student.select("rollcall_students.id, rollcall_students.first_name, rollcall_students.last_name, 
      rollcall_students.contact_first_name, rollcall_students.contact_last_name, rollcall_students.address, 
      rollcall_students.zip, rollcall_students.dob, rollcall_students.student_number, rollcall_students.phone, 
      rollcall_students.gender, rollcall_students.race, max(rollcall_student_daily_infos.grade) as grade")
    .joins('left join rollcall_student_daily_infos on rollcall_student_daily_infos.student_id = rollcall_students.id')
    .where("school_id = ?", params[:school_id])
    .order("NULLIF(last_name, '') asc, NULLIF(first_name, '') asc")
    .group("rollcall_students.id, rollcall_students.first_name, rollcall_students.last_name, 
      rollcall_students.contact_first_name, rollcall_students.contact_last_name, rollcall_students.address, 
      rollcall_students.zip, rollcall_students.dob, rollcall_students.student_number, rollcall_students.phone, 
      rollcall_students.gender, rollcall_students.race")
    @students = students.paginate(options)
    @students.total_entries = students.length
    respond_with(@students, @race_array = get_default_options[:race])
  end

  # POST rollcall/students
  def create
    report_date     =  Date.today.to_datetime.to_time
    student_obj     = Rollcall::Student.find_by_id(params[:student_id]) unless params[:student_id].blank?
    if student_obj.blank?
      student_obj = Rollcall::Student.create(
        :first_name         => params[:first_name],
        :last_name          => params[:last_name],
        :contact_first_name => params[:contact_first_name],
        :contact_last_name  => params[:contact_last_name],
        :address            => params[:address],
        :zip                => params[:zip],
        :gender             => params[:gender].first,
        :phone              => params[:phone].to_i,
        :race               => (get_default_options({:simple => true})[:race].index{ |rec, index| rec[:value] == params[:race]} || 0 ),
        :school_id          => params[:school_id].to_i,
        :dob                => DateTime.strptime(params[:dob].to_s, "%m/%d/%Y"),
        :student_number     => params[:student_number]
      )  
    end
    unless params[:symptom_list].blank?
      daily_info = Rollcall::StudentDailyInfo.create(
        :grade              => params[:grade].to_i,
        :confirmed_illness  => !params[:symptoms].blank?,
        :temperature        => params[:temperature],
        :treatment          => params[:treatment],
        :report_date        => report_date,
        :student_id         => student_obj.id,
        :date_of_onset      => report_date,
        :in_school          => true,
        :released           => true
      )
      unless ActiveSupport::JSON.decode(params[:symptom_list]).blank?
        ActiveSupport::JSON.decode(params[:symptom_list]).each do |rec|
          symptom_id      = Rollcall::Symptom.find_by_name(rec["name"]).id
          student_symptom = Rollcall::StudentReportedSymptom.create :student_daily_info_id => daily_info.id, :symptom_id => symptom_id
        end
      else
        symptom_id      = Rollcall::Symptom.find_by_name("None").id
        student_symptom = Rollcall::StudentReportedSymptom.create :student_daily_info_id => daily_info.id, :symptom_id => symptom_id
      end
    end
    @success = !student_obj.blank?
    respond_with(@success)
  end

  # PUT rollcall/students/:id
  def update
    student_record  = Rollcall::Student.find_by_id params[:id]
    student_success = student_record.update_attributes(
      :first_name         => params[:first_name],
      :last_name          => params[:last_name],
      :contact_first_name => params[:contact_first_name],
      :contact_last_name  => params[:contact_last_name],
      :address            => params[:address],
      :zip                => params[:zip],
      :phone              => params[:phone],
      :dob                => DateTime.strptime(params[:dob].to_s, "%m/%d/%Y"),
      :student_number     => params[:student_number],
      :gender             => params[:gender].first,
      :race               => (get_default_options({:simple => true})[:race].index{|rec| rec[:value] == params[:race]} || 0)
    )
    unless params[:student_info_id].blank?
      student_daily_record  = Rollcall::StudentDailyInfo.find(params[:student_info_id])
      student_daily_success = student_daily_record.update_attributes(
        :grade              => params[:grade].to_i,
        :confirmed_illness  => !params[:symptoms].blank?,
        :temperature        => params[:temperature],
        :treatment          => params[:treatment]
      )
      daily_infos = Rollcall::StudentReportedSymptom.find_all_by_student_daily_info_id(student_daily_record.id)
      unless params[:symptom_list].blank?
        symptom_list_or = []
        symptom_list_up = []
        daily_infos.each do |rec|
          symptom_list_or.push(rec.symptom)
        end
        ActiveSupport::JSON.decode(params[:symptom_list]).each do |rec|
          symptom_list_up.push(Rollcall::Symptom.find_by_name(rec["name"])) unless rec["name"].blank?
        end
        diff_result = symptom_list_or - symptom_list_up
        unless diff_result.blank?
          diff_result.each do |d|
            daily_infos.each do |rec|
              rec.destroy if rec.symptom.id == d.id
            end
          end
        else
          symptom_list_up.each do |s|
            r = Rollcall::StudentReportedSymptom.find_by_student_daily_info_id_and_symptom_id(student_daily_record.id,s.id)
            r = Rollcall::StudentReportedSymptom.create(:student_daily_info_id=>student_daily_record.id,:symptom_id=>s.id) if r.blank?
          end
        end
      else
        daily_infos.each do |r|
          r.destroy
        end
        Rollcall::StudentReportedSymptom.create(
          :student_daily_info_id => student_daily_record.id,
          :symptom_id            => Rollcall::Symptom.find_by_name("None").id
        )
      end
    end
    @success = student_success
    respond_with(@success)  
  end
  
   # POST rollcall/students/history
  def get_history    
    @daily_records = Rollcall::StudentDailyInfo.includes(:symptoms).where(student_id: params[:id])
    respond_with(@daily_records)
  end
end