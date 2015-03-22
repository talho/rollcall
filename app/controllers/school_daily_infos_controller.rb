class SchoolDailyInfosController < ApplicationController
  respond_to :html

  def index
    @schools = School.for_user(current_user)
    respond_with @schools
  end

  def create
    date = Date.new(params[:info_date][:year].to_i, params[:info_date][:month].to_i, params[:info_date][:day].to_i)

    params[:school_daily_infos].each do |k, p|
      next if p[:school_id].blank? || p[:absent].blank? && p[:enrollment].blank?
      sdi = SchoolDailyInfo.where(report_date: date, school_id: p[:school_id].to_i).first_or_initialize
      sdi.attributes = {total_absent: p[:absent], total_enrolled: p[:enrollment]}
      sdi.save if can? :manage, sdi
    end

    flash[:success] = "School Attendance Entered for #{I18n.l date, format: :short}"
    redirect_to school_daily_infos_path
  end
end
