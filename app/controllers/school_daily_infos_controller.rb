class SchoolDailyInfosController < ApplicationController
  def index
    @schools = School.for_user(current_user)
  end

  def create
    date = Date.new(params[:info_date][:year].to_i, params[:info_date][:month].to_i, params[:info_date][:day].to_i) if params[:info_date]

    params[:school_daily_infos].each do |k, p|
      school = School.where(tea_id: p[:state_id]).first if p[:school_id].blank?
      next if p[:school_id].blank? && school.blank? || p[:absent].blank? && p[:enrollment].blank?
      sdi = SchoolDailyInfo.where(report_date: date || p[:date], school_id: (p[:school_id] || school.id).to_i).first_or_initialize
      sdi.attributes = {total_absent: p[:absent], total_enrolled: p[:enrollment]}
      sdi.save if can? :manage, sdi
    end

    respond_to do |format|
      format.html do
        flash[:success] = "School Attendance Entered for #{I18n.l date, format: :short}"
        redirect_to school_daily_infos_path
      end
      format.json { render json: {}, status: 200 }
    end
  end
end
