class AlarmsController < ApplicationController
  before_action :load_alarm

  # GET /alarm/
  def show
  end

  # PATCH/PUT /alarm
  def update
    @alarm.attributes = alarm_params
    if @alarm.save
      flash.now[:success] = 'Alarm was successfully updated.'
    end

    render :show
  end

  private
  def load_alarm
    @alarm = current_user.alarm
    @alarm = current_user.build_alarm if @alarm.blank?
  end

  def alarm_params
    params.require(:alarm).permit(:attendance_deviation, :ili_threshold, :confirmed_ili_threshold, :measles_threshold)
  end
end
