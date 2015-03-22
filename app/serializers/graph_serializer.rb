class GraphSerializer < ActiveModel::Serializer
  has_one :entity, embed: :objects
  has_many :infos, embed: :objects
end
