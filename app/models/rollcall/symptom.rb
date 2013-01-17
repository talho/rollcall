# == Schema Information
#
# Table name: rollcall_symptoms
#
# id,         :integer not null, primary
# icd9_code,  :string(255)
# name,       :string(255)

class Rollcall::Symptom < ActiveRecord::Base
  self.table_name = "rollcall_symptoms"
  has_many :symptom_tags, :class_name => "Rollcall::SymptomTag"
end
