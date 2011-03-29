class Rollcall::AdstController < Rollcall::RollcallAppController
  helper :rollcall
  before_filter :rollcall_required

  def index
    schools       = Rollcall::School.search(params)
    options       = {:page => params[:page] || 1, :per_page => params[:limit] || 6}
    schools_paged = schools.paginate(options)
    rrd_info = Array.new
    schools_paged.each do |school|
      rrd_info.push(Rollcall::Rrd.render_graphs(params, school))
    end

    schools_with_rrd = Array.new
    schools_paged.each_index { |i|
      schools_with_rrd.push(schools_paged[i].attributes.merge(rrd_info[i]))
    }

    original_included_root = ActiveRecord::Base.include_root_in_json
    ActiveRecord::Base.include_root_in_json = false
    respond_to do |format|
      format.json do
        render :json => {
          :success       => true,
          :total_results => schools.length,
          :results       => schools_with_rrd
        }
      end
    end
    ActiveRecord::Base.include_root_in_json = original_included_root
  end
  
  def export
    filename = "rollcall_csv_export"
    params.each { |key,value|
      case key
      when "absent"
        if value == "Confirmed+Illness"
          filename = "AB_#{filename}"
        end
      when "gender"
        if value == "Male"
          filename = "G-#{value}_#{filename}"
        elsif value == "Female"
          filename = "G-#{value}_#{filename}"
        end
      when "startdt"
        if value.index('...').blank?
          filename = "SD-#{Time.parse(value).strftime("%s")}_#{filename}"
        end
      when "enddt"
        if value.index('...').blank?
          filename = "ED-#{Time.parse(value).strftime("%s")}_#{filename}"
        end
      when "school"
        if value.index('...').blank?
          filename = "SC-#{value}_#{filename}"
        end
      when "school_type"
        if value.index('...').blank?
          filename = "ST-#{value}_#{filename}"
        end
      else
      end
    }
    Rollcall::Rrd.send_later(:export_rrd_data, params, filename, current_user)
    respond_to do |format|
      format.json do
        render :json => {
          :success => true
        }
      end
    end
  end

  def report
    Rollcall::Rrd.send_later(:generate_report, params, current_user)
    respond_to do |format|
      format.json do
        render :json => {
          :success => true  
        }
      end
    end
  end

  def get_options
    absenteeism = [
      {:id => 0, :value => 'Gross'},
      {:id => 1, :value => 'Confirmed Illness'}
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
    gender = [
      {:id => 0, :value => 'Select Gender...'},
      {:id => 1, :value => 'Male'},
      {:id => 2, :value => 'Female'}
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
    symptoms       = Rollcall::Symptom.find(:all)
    data_functions = [
      {:id => 0, :value => 'Raw'},
      {:id => 1, :value => 'Average'},
      {:id => 2, :value => 'Standard Deviation'}
    ]
    data_functions_adv = [
      {:id => 0, :value => 'Raw'},
      {:id => 1, :value => 'Average'},
      {:id => 2, :value => 'Moving Average 30 Day'},
      {:id => 3, :value => 'Moving Average 60 Day'},
      {:id => 4, :value => 'Standard Deviation'},
      {:id => 5, :value => 'Cusum'}
    ]

    schools      = current_user.schools(:order => "display_name")
    zipcodes     = current_user.school_districts.map{|s| s.zipcodes.map{|i| {:id => i, :value => i}}}.flatten
    school_types = current_user.school_districts.map{|s| s.school_types.map{|i| {:id => i, :value => i}}}.flatten

    respond_to do |format|
      format.json do
        original_included_root = ActiveRecord::Base.include_root_in_json
        ActiveRecord::Base.include_root_in_json = false
        render :json => {
          :options => [{
            :absenteeism        => absenteeism,
            :age                => age,
            :data_functions     => data_functions,
            :data_functions_adv => data_functions_adv,
            :gender             => gender,
            :grade              => grade,
            :school_type        => school_types,
            :schools            => schools,
            :symptoms           => symptoms,
            :zipcode            => zipcodes
          }]
        }
        ActiveRecord::Base.include_root_in_json = original_included_root
      end
    end
  end

  def get_info
    alarm             = Rollcall::Alarm.find(params[:alarm_id])
    school_info       = Rollcall::SchoolDailyInfo.find_by_school_id_and_report_date params[:school_id],params[:report_date]
    confirmed_absents = Rollcall::StudentDailyInfo.find_all_by_school_id_and_report_date_and_confirmed_illness(
      params[:school_id],params[:report_date],true).size
    student_info      = Rollcall::StudentDailyInfo.find_all_by_school_id_and_report_date(params[:school_id],params[:report_date],true)

    respond_to do |format|
      format.json do
        original_included_root = ActiveRecord::Base.include_root_in_json
        ActiveRecord::Base.include_root_in_json = false
        render :json => {
          :info => [
            {
              :total_absent           => school_info.total_absent,
              :total_enrolled         => school_info.total_enrolled,
              :total_confirmed_absent => confirmed_absents,
              :alarm_severity         => alarm.alarm_severity,
              :school_name            => school_info.school.display_name,
              :school_type            => school_info.school.school_type,
              :students               => {:student_info => student_info.as_json}
            }  
          ]
        }
        ActiveRecord::Base.include_root_in_json = original_included_root
      end
    end
  end
end
