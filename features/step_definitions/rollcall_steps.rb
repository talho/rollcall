When /^I drop the following "([^\"]*)" file in the rollcall directory for "([^\"]*)"\:$/ do |type, isd, erb_file_template|
  rollcall_drop_dir = File.join(Rails.root, "vendor/plugins", "rollcall", "tmp", isd)
  Dir.ensure_exists(rollcall_drop_dir)
  file=ERB.new(erb_file_template).result
  f=File.open(File.join(rollcall_drop_dir, "#{type}_test.txt"), 'w')
  f.write(file)
  f.close
end

When /^the rollcall background worker processes for "([^\"]*)"$/ do |isd|
  require 'vendor/plugins/backgroundrb/server/lib/bdrb_server_helper.rb'
  require 'vendor/plugins/backgroundrb/server/lib/meta_worker.rb'
  require 'vendor/plugins/rollcall/lib/workers/rollcall_data_importer.rb'
  RollcallDataImporter.new.process_uploads("Houston")
end