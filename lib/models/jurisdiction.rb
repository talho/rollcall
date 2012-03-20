require 'dispatcher'

# Extend Jurisdiction to support many Rollcall School Districts
module Rollcall
  Dispatcher.to_prepare do
    ::Jurisdiction.class_eval do
      has_many :school_districts, :include => :schools, :class_name => "Rollcall::SchoolDistrict"
    end
  end
end
