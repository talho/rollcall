# == Schema Information
#
# Table name: rollcall_rrd
#
#  id                 :integer(4)      not null, primary key
#  file_name          :string(255)
#  school_id          :integer
#  created_at         :datetime
#  updated_at         :datetime
#

require 'spec/spec_helper'

describe Rollcall::Rrd do
  describe "validations" do
    before(:each) do
      @rrd=Factory(:rollcall_rrd)
    end
    it "should be valid" do
      @rrd.should be_valid
    end
  end

  describe "validates_presence_of" do
    before(:each) do
      @rrd = Factory(:rollcall_rrd)
    end
    context "school_id" do
      it "validates School ID" do
        @rrd.school_id.should_not be_blank
        Rollcall::School.all.should include(@rrd.school)
      end
    end
    context "file_name" do
      it "validates the file name" do
        @rrd.file_name.should_not be_blank  
      end
    end
  end

  describe "render_graphs" do
    before(:each) do
      @rrd = Factory(:rollcall_rrd)
    end
    it "returns a hash object containing the URI to the image and the rrd file id" do
      result = Rollcall::Rrd.render_graphs({:absent => 'gross'}, @rrd.school)
      result.should_not be_blank
      result[:image_url].should_not be_blank
      Rollcall::Rrd.find_by_id(result[:rrd_id]).should_not be_blank
    end
  end

  describe "export_rrd_data" do
    before(:each) do
      @user               = Factory(:user)
      @rrd                = Factory(:rollcall_rrd)
      #@school             = Factory(:rollcall_school)
      @role_membership    = Factory(:role_membership, :user => @user, :jurisdiction => @rrd.school.district.jurisdiction)
      #@rrd                = Factory(:rollcall_rrd)
      @result             = Rollcall::Rrd.export_rrd_data({:absent => 'gross'}, '11111111', @user)
    end
    it "returns true" do
      @result.should == true
    end
    it "creates a CSV document and exports the absenteeism data attached to the RRD data" do
      @user.documents.all.first[:file_file_name].should == @rrd[:file_name].gsub('.rrd', '.csv')
    end
  end

  describe "build_rrd" do
    before(:each) do
      @user               = Factory(:user)
      @school             = Factory(:rollcall_school)
      #@school             = Factory(:rollcall_school)
      @role_membership    = Factory(:role_membership, :user => @user, :jurisdiction => @school.district.jurisdiction)
      #@rrd                = Factory(:rollcall_rrd)
      @result             = Rollcall::Rrd.build_rrd('11111111', @school.id, Time.gm(Time.now().year, Time.now().month, Time.now().day))
    end
    it "returns an Rrd object" do
      Rollcall::Rrd.all.should include(@result)
    end
    it "creates a physical RRD file" do
      File.exists?(Dir.pwd << "/rrd/" << @result.file_name).should == true
    end
  end
#  TO BE IMPLEMENTED 
#  describe "generate_report" do
#    before(:each) do
#      @user = Factory(:user)
#      @rrd  = Factory(:rollcall_rrd)
#      @role_membership = Factory(:role_membership, :user => @user, :jurisdiction => @rrd.school.district.jurisdiction)
#      @result = Rollcall::Rrd.generate_report({:absent => 'gross'},@user)
#    end
#    it "returns true" do
#      @result.should == true
#    end
#    it "creates a "
#  end
end