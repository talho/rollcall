class AddMissingIndexesRollcall < ActiveRecord::Migration
  def self.up
    
    # These indexes were found by searching for AR::Base finds on your application
    # It is strongly recommanded that you will consult a professional DBA about your infrastucture and implemntation before
    # changing your database in that matter.
    # There is a possibility that some of the indexes offered below is not required and can be removed and not added, if you require
    # further assistance with your rails application, database infrastructure or any other problem, visit:
    #
    # http://www.railsmentors.org
    # http://www.railstutor.org
    # http://guides.rubyonrails.org

    
    add_index :schools, :district_id
    add_index :school_district_daily_infos, :school_district_id
    add_index :school_districts, :jurisdiction_id
    add_index :rollcall_alerts, [:id, :type]
    add_index :rollcall_alerts, :absentee_report_id
  end
  
  def self.down
    remove_index :schools, :district_id
    remove_index :school_district_daily_infos, :school_district_id
    remove_index :school_districts, :jurisdiction_id
    remove_index :rollcall_alerts, :column => [:id, :type]
    remove_index :rollcall_alerts, :absentee_report_id
  end
end
