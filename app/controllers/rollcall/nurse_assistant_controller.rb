class Rollcall::NurseAssistantController < Rollcall::RollcallAppController
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
    if !params[:search_term].blank?
      st              = "%" + CGI::unescape(params[:search_term]) + "%"
      students        = Rollcall::Student.find(
        :all,
        :conditions => ["student_number LIKE ? OR first_name LIKE ? OR last_name LIKE ? AND school_id", st, st, st, params[:school_id]])
      student_ids     = []
      students.collect{|rec| student_ids.push(rec.id) }
      unless student_ids.blank?
        student_records = Rollcall::StudentDailyInfo.find_by_sql("SELECT * FROM rollcall_student_daily_infos WHERE student_id IN (#{student_ids.join(",")})")
      else
        student_records = []
      end
    elsif !params[:filter_report_date].blank?
      student_records = Rollcall::StudentDailyInfo.find_all_by_report_date_and_school_id(
        params[:filter_report_date],
        params[:school_id],
        :include    => :student,
        :conditions => ["student_id = rollcall_students.id"]
      )
    else
      student_records = Rollcall::StudentDailyInfo.find_all_by_school_id(
        params[:school_id],
        :include    => :student,
        :conditions => ["student_id = rollcall_students.id"]
      )
    end
    student_records.each do |record|
      symptom_array  = []
      student_obj    = record.student
      record.symptoms.each do |symptom|
        symptom_array.push(symptom.name)
      end
      record[:symptom]            = symptom_array.join(",")
      record[:first_name]         = record.student.first_name
      record[:last_name]          = record.student.last_name
      record[:contact_first_name] = record.student.contact_first_name
      record[:contact_last_name]  = record.student.contact_last_name
      record[:address]            = record.student.address
      record[:zip]                = record.student.zip
      record[:dob]                = record.student.dob
      record[:student_number]     = record.student.student_number
      record[:phone]              = record.student.phone
      record[:gender]             = record.student.gender
      record[:student_id]         = record.student.id
      record[:race]               = race.each do |rec, index| rec[:value] == record.student.race ? index : 0  end
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

  def destroy
    result = false
    result = Rollcall::StudentDailyInfo.find(params[:id]).destroy
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
      {:id => 2, :value => 'Black'},
      {:id => 3, :value => 'Asian'},
      {:id => 4, :value => 'Hispanic'},
      {:id => 5, :value => 'Native American'},
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
    schools              = current_user.schools
    student              = Rollcall::Student.find_by_user_id(current_user.id, :order => "created_at DESC")
    unless student.blank?
      school_id            = student.school_id
      app_init             = false
      total_enrolled_alpha = Rollcall::SchoolDailyInfo.find_all_by_school_id(school_id).blank?
    else     
      school_id            = 0
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
            :app_init             => app_init,
            :school_id            => school_id,
            :school_name          => Rollcall::School.find_by_id(school_id).display_name,
            :schools              => schools
          }]
        }
        ActiveRecord::Base.include_root_in_json = original_included_root
      end
    end
  end

end