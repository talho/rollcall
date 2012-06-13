Then /^"([^\"]*)" should( not)? receive an email(?: with)?(?: title "([^\"]*)")?(?: message "([^"]*)")?$/ do |user_email, neg, title, message|
  debugger
  email = ActionMailer::Base.deliveries.detect do |email|
    status = false
    if(!email.bcc.blank?)
      status ||= email.bcc.include?(user_email)
    end
    if(!email.to.blank?)
      status ||= email.to.include?(user_email)
    end

    status &&= email.subject =~ /#{Regexp.escape(title)}/ unless title.nil?
    status &&= email.body =~ /#{Regexp.escape(message.gsub(/\\n/, "\n"))}/ unless message.nil?
    status
  end

  email.should_not be_nil if neg.nil?
  email.should be_nil if !neg.nil?
end