require 'factory_girl'

Factory.define :school_district, :class => Rollcall::SchoolDistrict do |m|
  m.sequence(:name){|t| "Name ##{t}"}
  m.association :jurisdiction
end

Factory.define :school , :class => Rollcall::School do |m|
  m.sequence(:name){|t| "Name ##{t}"}
  m.sequence(:display_name) {|t| "Display Name ##{t}"}
  m.level "ES"
  m.sequence(:school_number) {|num| num}
  m.association :district, :factory => :school_district
end

Factory.define :symptom , :class => Rollcall::Symptom do |m|
  m.sequence(:name){|t| "Name ##{t}"}
  m.sequence(:display_name) {|t| "Display Name ##{t}"}
  m.level "ES"
  m.sequence(:school_number) {|num| num}
  m.association :district, :factory => :school_district
end