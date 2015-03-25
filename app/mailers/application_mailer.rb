class ApplicationMailer < ActionMailer::Base
  default from: "no-reply@talho.org"
  layout 'mailer'
end
