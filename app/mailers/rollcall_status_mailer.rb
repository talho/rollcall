class RollcallStatusMailer < ApplicationMailer
  def send_status(users, school_districts, schools)
    @school_districts = school_districts
    @schools = schools

    mail(bcc: users.map(&:formatted_email), subject: "Rollcall Status Report")
  end
end
