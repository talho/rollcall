# Preview all emails at http://localhost:3000/rails/mailers/alarm_mailer
class AlarmMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/alarm_mailer/send_alarm
  def send_alarm
    AlarmMailer.send_alarm
  end

end
