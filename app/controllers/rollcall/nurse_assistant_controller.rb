class Rollcall::NurseAssistantController < Rollcall::RollcallAppController
  def index
    student_records = Rollcall::StudentDailyInfo.find(:all, :include => :student, :conditions => ["student_id = rollcall_students.id"])
    student_records.each do |record|
      symptom_array  = []
      student_obj    = record.student
      record.symptoms.each do |symptom|
        symptom_array.push(symptom.name)
      end
      record[:symptom]    = symptom_array.join(",")
      record[:first_name] = record.student.first_name
      record[:last_name]  = record.student.last_name
      record[:student]    = record.student
    end
    respond_to do |format|
      format.json do
        original_included_root                  = ActiveRecord::Base.include_root_in_json
        ActiveRecord::Base.include_root_in_json = false
        render :json => {
          :success       => true,
          :total_results => student_records.length,
          :results       => student_records
        }
        ActiveRecord::Base.include_root_in_json = original_included_root
      end
    end
  end

  def create
    report_date    = Time.now
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

    student_obj = Rollcall::Student.create(
      :first_name         => params[:first_name],
      :last_name          => params[:last_name],
      :contact_first_name => params[:contact_first_name],
      :contact_last_name  => params[:contact_last_name],
      :address            => params[:address],
      :zip                => params[:zip],
      :gender             => params[:gender],
      :phone              => params[:phone].to_i,
      :race               => params[:race].to_i,
      :school_id          => params[:school_id].to_i,
      :dob                => Time.parse("#{params[:dob]}"),
      :student_number     => 0001,
      :user_id            => current_user.id
    )
    daily_info = Rollcall::StudentDailyInfo.create(
      :school_id          => params[:school_id],
      :grade              => params[:grade],
      :confirmed_illness  => !params[:symptoms].blank?,

      :treatment          => params[:action],
      :report_date        => report_date,
      :student_id         => student_obj.id,
      :date_of_onset      => report_date,
      :in_school          => true,
      :released           => true
    )
    symptom_id      = Rollcall::Symptom.find_by_name('Temperature').id
    student_symptom = Rollcall::StudentReportedSymptoms.create :student_daily_info_id => daily_info.id, :symptom_id => symptom_id
    tea_id          = Rollcall::School.find_by_id(params[:school_id]).tea_id
    file_name       = "#{tea_id}_absenteeism"
    rrd_result      = Rollcall::Rrd.update_rrd_data report_date, total_absent, total_enrolled, file_name
   
    respond_to do |format|
      format.json do
        render :json => {
          :success => !student_obj.blank?
        }
      end
    end
  end

  def update
    student_record = Rollcall::StudentDailyInfo.find(params[:id])
    success        = student_record.update_attributes params
    student_record.save if success
    respond_to do |format|
      format.json do
        render :json => {
          :success => success
        }
      end
    end
  end

  def destroy
    result = false
    result = Rollcall::Alarm.find(params[:id]).destroy
    respond_to do |format|
      format.json do
        render :json => {
          :success => result
        }
      end
    end
  end

  def get_options
    gender = [
      {:id => 0, :value => 'Select Gender...'},
      {:id => 1, :value => 'Male'},
      {:id => 2, :value => 'Female'}
    ]
    race = [
      {:id => 0, :value => 'Select Race...'},
      {:id => 1, :value => 'White'},
      {:id => 2, :value => 'Black or African American'},
      {:id => 3, :value => 'Asian'},
      {:id => 4, :value => 'American Indian or Alaska Native'},
      {:id => 5, :value => 'Native Hawaiian or other Pacific Islande'},
      {:id => 6, :value => 'Other'}
    ]
    age = [
      {:id => 0, :value => 'Select Age...'},
      {:id => 1, :value => '0'},
      {:id => 2, :value => '1'},
      {:id => 3, :value => '2'},
      {:id => 4, :value => '3'},
      {:id => 5, :value => '4'},
      {:id => 6, :value => '5'},
      {:id => 7, :value => '6'},
      {:id => 8, :value => '7'},
      {:id => 9, :value => '8'},
      {:id => 10, :value => '9'},
      {:id => 11, :value => '10'},
      {:id => 12, :value => '11'},
      {:id => 13, :value => '12'},
      {:id => 14, :value => '13'},
      {:id => 15, :value => '14'},
      {:id => 16, :value => '15'},
      {:id => 17, :value => '16'},
      {:id => 18, :value => '17'},
      {:id => 19, :value => '18'}
    ]
    grade = [
      {:id => 0, :value => 'Select Grade...'},
      {:id => 1, :value => 'Kindergarten (Pre-K)'},
      {:id => 2, :value => '1st Grade'},
      {:id => 3, :value => '2nd Grade'},
      {:id => 4, :value => '3rd Grade'},
      {:id => 5, :value => '4th Grade'},
      {:id => 6, :value => '5th Grade'},
      {:id => 7, :value => '6th Grade'},
      {:id => 8, :value => '7th Grade'},
      {:id => 9, :value => '8th Grade'},
      {:id => 10,:value => '9th Grade'},
      {:id => 11,:value => '10th Grade'},
      {:id => 12,:value => '11th Grade'},
      {:id => 13,:value => '12th Grade'}
    ]
    symptoms             = Rollcall::Symptom.find(:all)
    zipcodes             = current_user.school_districts.map{|s| s.zipcodes.map{|i| {:id => i, :value => i}}}.flatten
    unless Rollcall::Student.find_by_user_id(current_user.id).blank?
      school_id            = Rollcall::Student.find_by_user_id(current_user.id).school_id
      app_init             = false
      total_enrolled_alpha = Rollcall::SchoolDailyInfo.find_all_by_school_id(school_id).blank?
    else
      app_init             = true
      total_enrolled_alpha = true
    end

    respond_to do |format|
      format.json do
        original_included_root                  = ActiveRecord::Base.include_root_in_json
        ActiveRecord::Base.include_root_in_json = false
        render :json => {
          :options => [{
            :race                 => race,
            :age                  => age,
            :gender               => gender,
            :grade                => grade,
            :symptoms             => symptoms,
            :zip                  => zipcodes,
            :total_enrolled_alpha => total_enrolled_alpha,
            :app_init             => app_init
          }]
        }
        ActiveRecord::Base.include_root_in_json = original_included_root
      end
    end
  end
end