class AddGmapInfo < ActiveRecord::Migration
  def self.up
    add_column :rollcall_schools, :gmap_lat, :float
    add_column :rollcall_schools, :gmap_lng, :float
    add_column :rollcall_schools, :gmap_addr, :string
  end

  def self.down
  end
end
