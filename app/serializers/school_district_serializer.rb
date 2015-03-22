class SchoolDistrictSerializer < ActiveModel::Serializer
  attributes :id, :name, :city, :county, :state, :state_id
end
