# == Schema Information
#
# Table name: symptom_tags
#
# id,         :integer not null, primary
# match,      :string(255)
# symptom_id, :integer
class SymptomTag < ActiveRecord::Base
  belongs_to :symptom
end
