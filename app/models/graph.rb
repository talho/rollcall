class Graph
  include ActiveModel::Serialization
  include ActiveModel::SerializerSupport

  attr_accessor :entity, :infos

  def initialize(entity, infos)
    @entity, @infos = entity, infos
  end
end
