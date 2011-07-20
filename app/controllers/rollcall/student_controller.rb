class Rollcall::StudentController < Rollcall::RollcallAppController
  
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
    students = Rollcall::Student.find_all_by_school_id(params[:school_id])
    students.each do |record|
      student_obj                 = record
      record[:grade]              = Rollcall::StudentDailyInfo.find_by_student_id(student_obj.id, :order => "created_at DESC").grade
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
      record[:student_id]         = student_obj.id
      record[:race]               = race.each do |rec, index| rec[:value] == student_obj.race ? index : 0  end
    end
    respond_to do |format|
      format.json do
        original_included_root                  = ActiveRecord::Base.include_root_in_json
        ActiveRecord::Base.include_root_in_json = false
        render :json => {
          :success       => true,
          :total_results => students.length,
          :results       => students
        }
        ActiveRecord::Base.include_root_in_json = original_included_root
      end
    end
  end

  def create
    report_date    = Time.gm(Time.now.year, Time.now.month, Time.now.day)
    school_info    = Rollcall::SchoolDailyInfo.find_by_school_id_and_report_date params[:school_id], report_date
    total_absent   = nil
    total_enrolled = nil

    if school_info.blank?
      if params[:total_enrolled_alpha_value]
        total_enrolled = params[:total_enrolled_alpha_value]
      else
        sdi            = Rollcall::SchoolDailyInfo.find_all_by_school_id(params[:school_id], :order => "report_date ASC")
        total_enrolled = sdi.last.total_enrolled
      end
      total_absent = 1
      school_info  = Rollcall::SchoolDailyInfo.create(
        :school_id          => params[:school_id],
        :total_absent       => total_absent,
        :total_enrolled     => total_enrolled,
        :report_date        => report_date
      )
    else
      total_enrolled = school_info.total_enrolled
      total_absent   = school_info.total_absent + 1
      school_info.update_attributes(
        :total_absent => total_absent,
        :report_date  => report_date
      )
      school_info.save!
    end
    race = [
      {:id => 0, :value => 'Select Race...'},
      {:id => 1, :value => 'White'},
      {:id => 2, :value => 'Black'},
      {:id => 3, :value => 'Asian'},
      {:id => 4, :value => 'Hispanic'},
      {:id => 5, :value => 'Native American'},
      {:id => 6, :value => 'Other'}
    ]
    student_obj = Rollcall::Student.find_by_student_number(params[:student_number])
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
    daily_info = Rollcall::StudentDailyInfo.create(
      :school_id          => params[:school_id],
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
    respond_to do |format|
      format.json do
        render :json => {
          :success => !student_obj.blank?
        }
      end
    end
  end

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
    student_daily_record = Rollcall::StudentDailyInfo.find(params[:id])
    student_record       = Rollcall::Student.find_by_id(student_daily_record.student_id)
    student_success      = student_record.update_attributes(
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
    student_daily_success = student_daily_record.update_attributes(
      :grade              => params[:grade].to_i,
      :confirmed_illness  => !params[:symptoms].blank?,
      :temperature        => params[:temperature],
      :treatment          => params[:treatment]
    )
    student_record.save if student_success
    respond_to do |format|
      format.json do
        render :json => {
          :success => student_daily_success
        }
      end
    end
  end
  
  def get_history
    daily_records = Rollcall::StudentDailyInfo.find_all_by_student_id(params[:id])
    daily_records.each do |rec|
      symptom_array  = []
      rec.symptoms.each do |symptom|
        symptom_array.push(symptom.name)
      end
      rec[:symptom] = symptom_array.join(",")
    end
    respond_to do |format|
      format.json do
        original_included_root                  = ActiveRecord::Base.include_root_in_json
        ActiveRecord::Base.include_root_in_json = false
        render :json => {
          :success       => true,
          :total_results => daily_records.length,
          :results       => daily_records
        }
        ActiveRecord::Base.include_root_in_json = original_included_root
      end
    end
  end
end