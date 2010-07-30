require File.join(File.dirname(__FILE__), 'models', 'user.rb')
require File.join(File.dirname(__FILE__), 'models', 'jurisdiction.rb')

# Add rollcall vendor/plugins/*/lib to LOAD_PATH
Dir[File.join(File.dirname(__FILE__), '../vendor/plugins/*/lib')].each do |path|
  $LOAD_PATH << path
end

# Require the open_flash_chart init.rb
require File.join(File.dirname(__FILE__), '..', 'vendor', 'plugins', 'open_flash_chart', 'init.rb')
