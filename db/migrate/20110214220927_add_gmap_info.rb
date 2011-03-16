class AddGmapInfo < ActiveRecord::Migration
  def self.up
    add_column :rollcall_schools, :gmap_lat, :float
    add_column :rollcall_schools, :gmap_lng, :float
    add_column :rollcall_schools, :gmap_addr, :string
  end

  def self.down
    remove_column :rollcall_schools, :gmap_lat
    remove_column :rollcall_schools, :gmap_lng
    remove_column :rollcall_schools, :gmap_addr
  end
end
