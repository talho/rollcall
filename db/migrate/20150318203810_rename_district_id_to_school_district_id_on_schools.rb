class RenameDistrictIdToSchoolDistrictIdOnSchools < ActiveRecord::Migration
  def change
    rename_column :schools, :district_id, :school_district_id
  end
end
