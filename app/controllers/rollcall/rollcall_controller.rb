=begin
    OpenPHIN is an opensource implementation of the CDC guidelines for 
    a public health information network.
    
    Copyright (C) 2009  Texas Association of Local Health Officials

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as
    published by the Free Software Foundation, either version 3 of the
    License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

=end

class Rollcall::RollcallController < Rollcall::RollcallAppController
  app_toolbar "rollcall"
  helper :rollcall
  before_filter :rollcall_required, :except => :about

  def about
  end

  def index
    toolbar = current_user.roles.include?(Role.find_by_name('Rollcall')) ? "rollcall" : "application"
    Rollcall::RollcallController.app_toolbar toolbar
    @districts = current_user.jurisdictions.map(&:school_districts).flatten!
    if @districts.empty? || !current_user.roles.include?(Role.find_by_name('Rollcall'))
      flash[:notice] = "You do not currently have any school districts in your jurisdiction enrolled in Rollcall.  Email your OpenPHIN administrator for more information."
      render "about"
    end
    @chart=open_flash_chart_object(600, 300, rollcall_summary_chart_path(params[:timespan]))
  end



  ##data for summary chart on rollcall index
  def summary_chart
    timespan = params[:timespan].nil? ? 7 : params[:timespan].to_i

    summary_chart=OpenFlashChart.new("Absenteeism Rates (Last #{timespan} days)")
    summary_chart.bg_colour = "#FFFFFF"

    lines=current_user.school_districts.map do |d|
      line=LineHollow.new
      line.text = d.name
      line.values = recent_data(d, timespan)
      line
    end
    max=current_user.school_districts.map{|d| d.recent_absentee_rates(timespan).max{|a,b| a=0 if a.nil?; b=0 if b.nil?; a <=> b} }.max
    xa= XAxis.new
    xa.labels=XAxisLabels.new(:labels => generate_time_labels(timespan), :rotate => 315, :visible_steps => 7, :size => 18)
    xa.steps = 7
    summary_chart.set_x_axis xa

    summary_chart.y_axis = YAxis.new(
        :steps => 2,
        :min => 0,
        :max => max
    )

    lines.each do |l|
      summary_chart.add_element(l)
    end
    render :text => summary_chart.to_s, :layout => false
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
    symptoms = [
      {:id => 0, :value => 'Select Symptom...'},
      {:id => 1, :value => 'Temperature'},
      {:id => 2, :value => 'Lethargy'},
      {:id => 3, :value => 'Sore Throat'},
      {:id => 4, :value => 'Congestion'},
      {:id => 5, :value => 'Diarrhea'},
      {:id => 6, :value => 'Headache'},
      {:id => 7, :value => 'Cough'},
      {:id => 8, :value => 'Body Ache'},
      {:id => 9, :value => 'Vomiting'},
      {:id => 10,:value => 'Rhinorrhea'}
    ]
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
  
  private
  def recent_data(district, timespan)
    data = []
    (timespan-1).days.ago.to_date.upto Date.today do |date|
      rate=district.average_absence_rate(date)
      data.push rate.nil? ? nil : DotValue.new(district.average_absence_rate(date), nil, :tip => "#{date.strftime("%x")}\n#val#%")
    end
    data
  end
  def generate_time_labels(timespan)
    xlabels=[]
    timespan.days.ago.to_date.upto Date.today do |date|
      if date.day == 1
        #label beginning of month
        xlabels.push date.strftime("%B %e")
      elsif date.wday == 1
        #label beginning of week
        xlabels.push date.strftime("%a (Week %W)")
      else
        xlabels.push timespan > 14 ? "" : date.strftime("%m/%d")
      end
    end
    xlabels
  end

end
