require "rails_helper"

RSpec.describe AlarmMailer, type: :mailer do
  describe "send_alarm" do
    let(:mail) { AlarmMailer.send_alarm }

    it "renders the headers" do
      expect(mail.subject).to eq("Send alarm")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

end
