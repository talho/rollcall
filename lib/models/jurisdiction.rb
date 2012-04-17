
# Extend Jurisdiction to support many Rollcall School Districts
module Rollcall
  module Jurisdiction
    def self.included(base)
      base.has_many :school_districts, :include => :schools, :class_name => "Rollcall::SchoolDistrict"
    end
  end
end
