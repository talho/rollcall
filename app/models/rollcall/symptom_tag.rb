class Rollcall::SymptomTag < ActiveRecord::Base
  self.table_name = 'rollcall_symptom_tags'
  belongs_to :symptom, :class_name => 'Rollcall::Symptom'
end
