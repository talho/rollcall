class AlarmMailer < ApplicationMailer
  def send_alarm alarm, abnormal_schools, ili_schools, confirmed_ili_schools, measles_schools
    @alarm, @abnormal_schools, @ili_schools, @confirmed_ili_schools, @measles_schools = alarm, abnormal_schools, ili_schools, confirmed_ili_schools, measles_schools
    mail to: alarm.user.email,
         subject: "Rollcall Alarm"
  end
end
