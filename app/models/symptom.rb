# == Schema Information
#
# Table name: symptoms
#
# id,         :integer not null, primary
# icd9_code,  :string(255)
# name,       :string(255)

class Symptom < ActiveRecord::Base
  has_many :symptom_tags
end
