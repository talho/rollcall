require 'factory_girl'

Factory.define :school_district do |m|
  m.sequence(:name){|t| "Name ##{t}"}
  m.association :jurisdiction
end

Factory.define :school do |m|
  m.sequence(:name){|t| "Name ##{t}"}
  m.sequence(:display_name) {|t| "Display Name ##{t}"}
  m.level "ES"
  m.sequence(:school_number) {|num| num}
  m.association :district, :factory => :school_district
end
