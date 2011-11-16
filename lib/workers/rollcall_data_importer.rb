=begin
    OpenPHIN is an opensource implementation of the CDC guidelines for 
    a public health information network.
    
    Copyright (C) 2009  Texas Association of Local Health Officials

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as
    published by the Free Software Foundation, either version 3 of the
    License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

=end

class RollcallDataImporter < BackgrounDRb::MetaWorker
  set_worker_name :rollcall_data_importer
  #reload_on_schedule true

  def create(args = nil)
    #logger.warn("Creating new daily information for Schools, School Districts, Students, and Student Reported Symptoms")
  end

  def process_uploads(isd = nil)
    #logger.warn("Running TransformImportWorker")
    if RAILS_ENV == "production"
      rollcall_data_path = File.join("/var/www/openphin/shared", "rollcall")
    elsif RAILS_ENV == "test" || RAILS_ENV == "cucumber"
      rollcall_data_path = File.join(File.dirname(__FILE__), "..", "..", "..", "vendor", "plugins", "rollcall", "tmp")
    end
    unless isd.blank?
      SchoolDataTransformer.new(rollcall_data_path, "#{isd}").transform_and_import
    else
      Rollcall::SchoolDistrict.all.each do |district|
        SchoolDataTransformer.new(rollcall_data_path, "#{district.name}").transform_and_import
      end
    end
    Rollcall::AlarmQuery.find_all_by_alarm_set(true).each do |a|
      a.generate_alarm
    end
  end
end