# == Schema Information
#
# Table name: rollcall_symptoms
#
# id,         :integer not null, primary
# icd9_code,  :string(255)
# name,       :string(255)

class Rollcall::Symptom < Rollcall::Base
  set_table_name "rollcall_symptoms" 
end