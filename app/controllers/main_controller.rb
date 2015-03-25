class MainController < ApplicationController
  def index
    # we need:
    # - Overall absentee rate, ili & confirmed illnesses
    # - School district absentee rate, ili & confirmed illnesses
    # - Schools reporting confirmed illnesses & ili
    # - Schools w/ absenteism beyond std deviation

    @report = Report.new(current_user)
  end
end
