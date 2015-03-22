class SchoolSerializer < ActiveModel::Serializer
  attributes :id, :name, :postal_code, :school_number, :tea_id, :school_type, :gmap_lat, :gmap_lng, :gmap_addr

  has_one :school_district
end
