# Require rollcall models
Dir[File.join(File.dirname(__FILE__), 'models', '*.rb')].each do |f|
  require f
end

# Add rollcall vendor/plugins/*/lib to LOAD_PATH
Dir[File.join(File.dirname(__FILE__), '../vendor/plugins/*/lib')].each do |path|
  $LOAD_PATH << path
end

# Require the open_flash_chart init.rb
require File.join(File.dirname(__FILE__), '..', 'vendor', 'plugins', 'open_flash_chart', 'init.rb')

# Register the plugin expansion in the $expansion_list global variable
$expansion_list = [] unless defined?($expansion_list)
$expansion_list.push(:rollcall) unless $expansion_list.index(:rollcall)

# Register any required javascript or stylesheet files with the appropriate
# rails expansion helper
ActionView::Helpers::AssetTagHelper.register_javascript_expansion(
  :rollcall => [ "rollcall/rollcall" ])
ActionView::Helpers::AssetTagHelper.register_stylesheet_expansion(
  :rollcall => [])
