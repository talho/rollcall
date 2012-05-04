When /^I drop the following "([^\"]*)" file in the rollcall directory for "([^\"]*)"\:$/ do |type, isd, erb_file_template|
  rollcall_drop_dir = File.join(Rails.root.to_s, "vendor/extensions", "rollcall", "tmp", isd)
  Dir.ensure_exists(rollcall_drop_dir)
  file=ERB.new(erb_file_template).result
  f=File.open(File.join(rollcall_drop_dir, "#{type}_test.txt"), 'w')
  f.write(file)
  f.close
end

When /^the rollcall background worker processes for "([^\"]*)"$/ do |isd|
  require File.join(File.dirname(__FILE__), "..","..","lib","workers","rollcall_data_importer.rb")
  RollcallDataImporter.new().process_uploads(isd)
end