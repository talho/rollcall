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

# Load the rrdtool yaml config file
yml = YAML.load_file(File.join(File.dirname(__FILE__), '..', 'config', 'rrdtool.yml'))
ROLLCALL_RRDTOOL_CONFIG = yml[Rails.env]
ROLLCALL_RRDTOOL_CONFIG.freeze

# Require the rails_rrdtool init.rb
require File.join(File.dirname(__FILE__), '..', 'vendor', 'plugins', 'rails_rrdtool', 'init.rb')

# Register the plugin expansion in the $expansion_list global variable
$expansion_list = [] unless defined?($expansion_list)
$expansion_list.push(:rollcall) unless $expansion_list.index(:rollcall)

# Build the menu in the $menu_config global variable
$menu_config = {} unless defined?($menu_config)
$menu_config[:rollcall] = "{name: 'Rollcall', items:[
            {name: 'ADST', tab:{id: 'rollcall_adst', title:'Rollcall ADST', url:'', initializer: 'Talho.Rollcall.ADST'}},
            {name: 'Nurse Assistant', tab:{id: 'rollcall_nurse', title:'Nurse Assistant', url:'', initializer: 'Talho.Rollcall.NurseAssistant'}},
            {name: 'Schools', tab:{id: 'rollcall_schools', title:'Rollcall Schools', url:'', initializer: 'Talho.Rollcall'}},
            {name: 'About Rollcall', tab:{id: 'about_rollcall', title:'About Rollcall', url:''}}]}"

# Register any required javascript or stylesheet files with the appropriate
# rails expansion helper
ActionView::Helpers::AssetTagHelper.register_javascript_expansion(
  :rollcall => [ "rollcall/script_config" ])
ActionView::Helpers::AssetTagHelper.register_stylesheet_expansion(
  :rollcall => [ "rollcall/rollcall" ])