class Rollcall::NurseAssistantController < Rollcall::RollcallAppController
  def index
    student_records = current_user.nurse_assistant(params)
    respond_to do |format|
      format.json do
        original_included_root = ActiveRecord::Base.include_root_in_json
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
    result = Rollcall::NurseAssistant.create_associative_data params, current_user.id
    respond_to do |format|
      format.json do
        render :json => {
          :success => result
        }
      end
    end
  end

  def update
    student_record = Rollcall::NurseAssistant.find(params[:id])
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
    total_enrolled_alpha = Rollcall::SchoolDailyInfo.find_all_by_school_id(obj.school_id).blank?
    respond_to do |format|
      format.json do
        original_included_root = ActiveRecord::Base.include_root_in_json
        ActiveRecord::Base.include_root_in_json = false
        render :json => {
          :options => [{
            :race                 => race,
            :age                  => age,
            :gender               => gender,
            :grade                => grade,
            :symptoms             => symptoms,
            :zipcode              => zipcodes,
            :total_enrolled_alpha => total_enrolled_alpha
          }]
        }
        ActiveRecord::Base.include_root_in_json = original_included_root
      end
    end
  end
end