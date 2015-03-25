require "rails_helper"

RSpec.describe AlarmsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/alarms").to route_to("alarms#index")
    end

    it "routes to #new" do
      expect(:get => "/alarms/new").to route_to("alarms#new")
    end

    it "routes to #show" do
      expect(:get => "/alarms/1").to route_to("alarms#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/alarms/1/edit").to route_to("alarms#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/alarms").to route_to("alarms#create")
    end

    it "routes to #update" do
      expect(:put => "/alarms/1").to route_to("alarms#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/alarms/1").to route_to("alarms#destroy", :id => "1")
    end

  end
end
