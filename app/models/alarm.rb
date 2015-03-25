class Alarm < ActiveRecord::Base
  belongs_to :user

  def self.process
    #look for alarms set
    Alarm.includes(:user).where("attendance_deviation = 't' OR ili_threshold > 0 OR confirmed_ili_threshold > 0 OR measles_threshold > 0").each do |alarm|
      # process attendance
      @report = Report.new(alarm.user, 2)
      if alarm.attendance_deviation
        @abnormal_schools = @report.school_districts.map{|sd| sd[:schools_above_average].to_a }.flatten
      end
      # process ili
      if alarm.ili_threshold.present? && alarm.ili_threshold >= 0
        @ili_schools = @report.school_districts.map{|sd| sd[:schools_with_ili].to_a }.flatten
      end
      # process confirmed ili
      if alarm.confirmed_ili_threshold.present? && alarm.confirmed_ili_threshold >= 0
        @confirmed_ili_schools = @report.school_districts.map{|sd| sd[:schools_with_ili].reject{|s| s.confirmed < 1 } }.flatten
      end
      # process measles
      if alarm.measles_threshold.present? && alarm.measles_threshold >= 0
        @measles_schools = @report.school_districts.map{|sd| sd[:schools_with_measles].to_a }.flatten
      end

      if !@abnormal_schools.blank? || (@ili_schools.present? && alarm.ili_threshold.present? && @ili_schools.length >= alarm.ili_threshold) ||
         (@confirmed_ili_schools.present? && alarm.confirmed_ili_threshold.present? && @confirmed_ili_schools.length >= alarm.confirmed_ili_threshold) ||
         (@measles_schools.present? && alarm.measles_threshold.present? && @measles_schools.length >= alarm.measles_threshold)
        AlarmMailer.send_alarm(alarm, @abnormal_schools, @ili_schools, @confirmed_ili_schools, @measles_schools).deliver_now
      end
    end
  end
end
