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

  def create(args = nil)
    ROLLCALL_LOGGER.warn("#{Time.now} - Creating new daily information for Schools, School Districts, Students, and Student Reported Symptoms")
  end

  # Method start the transformation and import sequence for Rollcall
  #
  # @param isd optional parameter to call method if only wanting to process a certain ISD
  def process_uploads(isd = nil)
    ROLLCALL_LOGGER.warn("#{Time.now} - Running TransformImportWorker")
    if Rails.env == "production"
      rollcall_data_path = File.join("/var/www/openphin/shared", "rollcall")
    elsif Rails.env == "test" || Rails.env == "cucumber"
      rollcall_data_path = File.join(File.dirname(__FILE__), "..", "..", "tmp")
    end
    unless isd.blank?
      begin
        SchoolDataTransformer.new(rollcall_data_path, isd.to_s).transform_and_import
      rescue Exception => e
        raise e if Rails.env == "test" || Rails.env == "cucumber"
      end
    else
      Rollcall::SchoolDistrict.all.each do |district|
        begin
          ROLLCALL_LOGGER.warn("#{Time.now} - Importing daily info for #{district.name.to_s}")
          SchoolDataTransformer.new(rollcall_data_path, district.name.to_s).transform_and_import
        rescue Exception => e
          ROLLCALL_LOGGER.error("#{Time.now} - Exception: #{e.message}")
          raise e if Rails.env == "test" || Rails.env == "cucumber"
        end
      end
    end
    Rollcall::AlarmQuery.find_all_by_alarm_set(true).each do |a|
      a.generate_alarm
    end
  end
end
