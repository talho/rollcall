class SchoolDistrictUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :school_district
  enum role: [:staff, :admin]
end
