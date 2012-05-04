# == Schema Information
#
# Table name: rollcall_alerts
#
# id,       :integer not null, primary
# alarm_id, :integer not null, foreign key
# alert_id, :integer not null, foreign key
#
require 'spec/spec_helper'
require File.dirname(__FILE__) + "/../factories.rb"

describe RollcallAlert do
  before(:each) do
    @rollcall_alert=FactoryGirl.create(:rollcall_alert)
  end
  describe "validations" do
    it "should be valid" do
      @rollcall_alert.should be_valid
    end
  end

  describe "belongs_to" do
    context "alarm" do
      it "returns the alarm associated with this Rollcall Alert" do
        Rollcall::Alarm.all.should include(@rollcall_alert.alarm)
      end
    end
  end

  describe "to_s" do
    it "returns the title if set or an empty string" do
      @rollcall_alert.to_s.should == @rollcall_alert.title
    end
  end

  describe "app" do
    it "returns the app associated with this Alert" do
      @rollcall_alert.app.should == "rollcall"
    end
  end

  describe "default_alert" do
    it "sets and returns a default alert" do
      RollcallAlert.all.length.should == 1
      ra = RollcallAlert.default_alert
      #ra.author    = FactoryGirl.create(:user)
      #ra.alarm_id  = FactoryGirl.create(:rollcall_alarm).id
      ra.save
      RollcallAlert.all.length.should == 2
      ra.title.should   == "Rollcall Alarm Alert"
      ra.message.should == "This message is intended to update the user on a newly created Alarm."
    end
  end

  describe "to_xml" do
    it "returns valid XML" do
      xp = XML::Parser.string(@rollcall_alert.to_xml)
      xp.parse.should be_kind_of(LibXML::XML::Document)
    end
    it "converts the alert into an xml object to be used by the Messaging API" do
      xp = Nokogiri.XML @rollcall_alert.to_xml
      xp.search("Behavior").should_not be_blank
      xp.search("IVRTree").should_not be_blank
    end
    it "overrides the provider to the talho email service" do
      xp = Nokogiri.XML @rollcall_alert.to_xml
      xp.search("Provider").first.attributes["name"].value.should == "talho"      
    end
  end
end