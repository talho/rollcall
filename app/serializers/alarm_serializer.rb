class AlarmSerializer < ActiveModel::Serializer
  attributes :id, :attendance_deviation, :ili_threshold, :confirmed_ili_threshold, :measles_threshold
  has_one :user
end
