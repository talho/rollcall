class Rollcall::AdstController < Rollcall::RollcallAppController
  helper :rollcall
  before_filter :rollcall_required

  def index
    results      = Rollcall::Rrd.search(params)
    options      = {:page => params[:page] || 1, :per_page => params[:limit] || 6}
    results_uniq = results.blank? ? results.paginate(options) : results.paginate(options)
    respond_to do |format|
      format.json do
        render :json => {
          :success       => true,
          :total_results => results.length,
          :results       => results_uniq.as_json
        }
      end
    end
  end
  
  def create
    results      = Rollcall::Rrd.render_graphs(params)
    schools      = params[:results][:schools].blank? ? "" : params[:results][:schools]
    school_names = []
    schools = schools.split(",").each do |school|
      school_names.push("#{Rollcall::School.find_by_tea_id(school).display_name}")
    end
    school_names.join(",")

    respond_to do |format|
      format.json do
        render :json => {
          :success       => true,
          :total_results => results[:image_urls].length,
          :results       => {
            :id           => 1,
            :img_urls     => results[:image_urls],
            :r_ids        => results[:rrd_ids],
            :schools      => schools,
            :school_names => school_names
          }.as_json
        }
      end
    end
  end

  def export
    filename = "csv_export"
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
      else
      end
    }
    results = Rollcall::Rrd.export_rrd_data params
    send_data results, :type => 'application/csv', :filename => "#{filename}.csv"
  end

  def get_options
    absenteeism = [
      {:id => 0, :value => 'Gross'},
      {:id => 1, :value => 'Confirmed Illness'}
    ]
    age = [
      {:id => 0, :value => 'Select Age...'},
      {:id => 1, :value => '3-4'},
      {:id => 2, :value => '5-6'},
      {:id => 3, :value => '7-8'},
      {:id => 4, :value => '9-10'},
      {:id => 5, :value => '11-12'},
      {:id => 6, :value => '13-14'},
      {:id => 7, :value => '15-16'},
      {:id => 8, :value => '17-18'}
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
    data_functions = if params[:type] == 'simple' || params[:type].blank?
      [
        {:id => 0, :value => 'Raw'},
        {:id => 1, :value => 'Average'},
        {:id => 2, :value => 'Standard Deviation'}
      ]
    elsif params[:type] == 'advanced'
      [
        {:id => 0, :value => 'Raw'},
        {:id => 1, :value => 'Average'},
        {:id => 2, :value => 'Moving Average 30 Day'},
        {:id => 3, :value => 'Moving Average 60 Day'},
        {:id => 4, :value => 'Standard Deviation'},
        {:id => 5, :value => 'Cusum'}
      ]
    end

    schools      = current_user.schools(:order => "display_name")
    zipcodes     = current_user.school_districts.map{|s| s.zipcodes.map{|i| {:id => i, :value => i}}}.flatten
    school_types = current_user.school_districts.map{|s| s.school_types.map{|i| {:id => i, :value => i}}}.flatten

    respond_to do |format|
      format.json do
        original_included_root = ActiveRecord::Base.include_root_in_json
        ActiveRecord::Base.include_root_in_json = false
        render :json => {
          :options => [
            {:absenteeism    => absenteeism.as_json},
            {:age            => age.as_json},
            {:data_functions => data_functions.as_json},
            {:gender         => gender.as_json},
            {:grade          => grade.as_json},
            {:school_type    => school_types.as_json},
            {:schools        => schools.as_json},
            {:symptoms       => symptoms.as_json},
            {:zipcode        => zipcodes.as_json}
          ]
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