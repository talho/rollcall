class Rollcall::StudentController < Rollcall::RollcallAppController
  before_filter :rollcall_student_required
  # GET rollcall/students
  def index
    race = [
      {:id => 0, :value => 'Select Race...'},
      {:id => 1, :value => 'White'},
      {:id => 2, :value => 'Black'},
      {:id => 3, :value => 'Asian'},
      {:id => 4, :value => 'Hispanic'},
      {:id => 5, :value => 'Native American'},
      {:id => 6, :value => 'Other'}
    ]

    students       = Rollcall::Student.find_all_by_school_id(params[:school_id])
    unless params[:start].blank?
      per_page = params[:limit].to_i
      if params[:start].to_i == 0
        page = 1
      else
        page = (params[:start].to_i / per_page) + 1
      end    
      options = {:page => page, :per_page => per_page}
    else
      options = {}
    end   
    students_paged = students.paginate(options)
    students_paged.each do |record|
      student_obj                 = record
      student_daily_info          = Rollcall::StudentDailyInfo.find_by_student_id(student_obj.id, :order => "created_at DESC")
      record[:grade]              = student_daily_info.blank? ? nil : student_daily_info.grade
      record[:first_name]         = student_obj.first_name.blank? ? "Unknown" : student_obj.first_name
      record[:last_name]          = student_obj.last_name.blank? ? "Unknown" : student_obj.last_name
      record[:contact_first_name] = student_obj.contact_first_name.blank? ? "Unknown" : student_obj.contact_first_name
      record[:contact_last_name]  = student_obj.contact_last_name.blank? ? "Unknown" : student_obj.contact_last_name
      record[:address]            = student_obj.address.blank? ? "Unknown" : student_obj.address
      record[:zip]                = student_obj.zip.blank? ? "Unknown" : student_obj.zip
      record[:dob]                = student_obj.dob.blank? ? "Unknown" : student_obj.dob
      record[:student_number]     = student_obj.student_number.blank? ? "Unknown" : student_obj.student_number
      record[:phone]              = student_obj.phone.blank? ? "Unknown" : student_obj.phone
      record[:gender]             = student_obj.gender.blank? ? "Unknown" : student_obj.gender
      record[:race]               = race.each do |rec, index| rec[:value] == student_obj.race ? index : 0  end
    end
    respond_to do |format|
      format.json do
        render :json => {
          :success       => true,
          :total_results => students.length,
          :results       => students_paged
        }
      end
    end
  end

  # POST rollcall/students
  def create
    report_date = Time.gm(Time.now.year, Time.now.month, Time.now.day)
    race        = [
      {:id => 0, :value => 'Select Race...'},
      {:id => 1, :value => 'White'},
      {:id => 2, :value => 'Black'},
      {:id => 3, :value => 'Asian'},
      {:id => 4, :value => 'Hispanic'},
      {:id => 5, :value => 'Native American'},
      {:id => 6, :value => 'Other'}
    ]
    student_obj = Rollcall::Student.find_by_id(params[:student_id]) unless params[:student_id].blank?
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
        :race               => race.each do |rec, index| rec[:value] == params[:race] ? index : 0  end,
        :school_id          => params[:school_id].to_i,
        :dob                => Time.parse("#{params[:dob]}"),
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
    respond_to do |format|
      format.json do
        render :json => {
          :success => !student_obj.blank?
        }
      end
    end
  end

  # PUT rollcall/students/:id
  def update
    race = [
      {:id => 0, :value => 'Select Race...'},
      {:id => 1, :value => 'White'},
      {:id => 2, :value => 'Black'},
      {:id => 3, :value => 'Asian'},
      {:id => 4, :value => 'Hispanic'},
      {:id => 5, :value => 'Native American'},
      {:id => 6, :value => 'Other'}
    ]

    student_record  = Rollcall::Student.find_by_id params[:id]
    student_success = student_record.update_attributes(
      :first_name         => params[:first_name],
      :last_name          => params[:last_name],
      :contact_first_name => params[:contact_first_name],
      :contact_last_name  => params[:contact_last_name],
      :address            => params[:address],
      :zip                => params[:zip],
      :phone              => params[:phone],
      :dob                => Time.parse("#{params[:dob]}"),
      :student_number     => params[:student_number],
      :gender             => params[:gender].first,
      :race               => race.each do |rec, index| rec[:value] == params[:race] ? index : 0  end
    )
    student_record.save if student_success
    unless params[:student_info_id].blank?
      student_daily_record  = Rollcall::StudentDailyInfo.find(params[:student_info_id])
      student_daily_success = student_daily_record.update_attributes(
        :grade              => params[:grade].to_i,
        :confirmed_illness  => !params[:symptoms].blank?,
        :temperature        => params[:temperature],
        :treatment          => params[:treatment]
      )
      student_daily_record.save if student_daily_success
      daily_infos = Rollcall::StudentReportedSymptom.find_all_by_student_daily_info_id(student_daily_record.id)
      unless params[:symptom_list].blank?
        symptom_list_or = []
        symptom_list_up = []
        daily_infos.each do |rec|
          symptom_list_or.push(rec.symptom)
        end
        ActiveSupport::JSON.decode(params[:symptom_list]).each do |rec|
          symptom_list_up.push(Rollcall::Symptom.find_by_name(rec["name"]))
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
    respond_to do |format|
      format.json do
        render :json => {
          :success => student_success
        }
      end
    end
  end
  
   # POST rollcall/students/history
  def get_history
    unless params[:id].blank?
      daily_records = Rollcall::StudentDailyInfo.find_all_by_student_id(params[:id])
      daily_records.each do |rec|
        symptom_array  = []
        rec.symptoms.each do |symptom|
          symptom_array.push(symptom.name)
        end
        rec[:symptom] = symptom_array.join(",")
      end
    else
      daily_records = {}
    end

    respond_to do |format|
      format.json do
        render :json => {
          :success       => true,
          :total_results => daily_records.length,
          :results       => daily_records
        }
      end
    end
  end
end