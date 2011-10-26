Dir[File.join(File.dirname(__FILE__), '../lib/*/')].each do |path|
  $LOAD_PATH << path 
end

# Add rollcall vendor/plugins/*/lib to LOAD_PATH
Dir[File.join(File.dirname(__FILE__), '../vendor/plugins/*/lib')].each do |path|
  $LOAD_PATH << path
end

# Require rollcall models
Dir[File.join(File.dirname(__FILE__), 'models', '*.rb')].each do |f|
  require f
end

# Require rollcall rollcall recipes
Dir[File.join(File.dirname(__FILE__), 'models', 'report', '*.rb')].each do |f|
  require f
end

# Require rollcall import scripts
Dir[File.join(File.dirname(__FILE__), 'import', '*.rb')].each do |f|
  require f
end

# Load the rrdtool yaml config file
rrd_yml = YAML.load_file(File.join(File.dirname(__FILE__), '..', 'config', 'rrdtool.yml'))
ROLLCALL_RRDTOOL_CONFIG = rrd_yml[Rails.env]
ROLLCALL_RRDTOOL_CONFIG.freeze

# Require the creation of rrd folders
if ROLLCALL_RRDTOOL_CONFIG["rrdfile_path"]
  Dir.ensure_exists(ROLLCALL_RRDTOOL_CONFIG["rrdfile_path"])
  File.symlink(ROLLCALL_RRDTOOL_CONFIG["rrdfile_path"], File.join(Rails.root, "rrd/")) unless File.symlink?(File.join(Rails.root, "rrd/"))
else
  Dir.ensure_exists(File.join(Rails.root, "rrd/"))
end

Dir.ensure_exists(File.join(Rails.root, "public/rrd/"))

# Require the rails_rrdtool init.rb
require File.join(File.dirname(__FILE__), '..', 'vendor', 'plugins', 'rails_rrdtool', 'init.rb')

# Register the plugin expansion in the $expansion_list global variable
$expansion_list = [] unless defined?($expansion_list)
$expansion_list.push(:rollcall) unless $expansion_list.index(:rollcall)


# Build the menu in the $menu_config global variable
$menu_config = {} unless defined?($menu_config)
$menu_config[:rollcall_admin] = "{name: 'Rollcall', items:[
            {name: 'ADST', tab:{id: 'rollcall_adst', title:'Rollcall ADST', url:'', initializer: 'Talho.Rollcall.ADST'}},
            {name: 'Nurse Assistant', tab:{id: 'rollcall_nurse_assistant', title:'Nurse Assistant', url:'', initializer: 'Talho.Rollcall.NurseAssistant'}},
            {name: 'Schools', tab:{id: 'rollcall_schools', title:'Rollcall Schools', url:'', initializer: 'Talho.Rollcall.Schools'}},
            {name: 'Admin', items:[
              {name: 'Users', tab:{id: 'rollcall_users', title:'Rollcall Users', url:'', initializer: 'Talho.Rollcall.Users'}}
            ]}]}"
#$menu_config[:rollcall_admin] = ""
$menu_config[:rollcall] = "{name: 'Rollcall', items:[
            {name: 'ADST', tab:{id: 'rollcall_adst', title:'Rollcall ADST', url:'', initializer: 'Talho.Rollcall.ADST'}},
            {name: 'Nurse Assistant', tab:{id: 'rollcall_nurse_assistant', title:'Nurse Assistant', url:'', initializer: 'Talho.Rollcall.NurseAssistant'}},
            {name: 'Schools', tab:{id: 'rollcall_schools', title:'Rollcall Schools', url:'', initializer: 'Talho.Rollcall.Schools'}}]}"

# Register any required javascript or stylesheet files with the appropriate
# rails expansion helper
ActionView::Helpers::AssetTagHelper.register_javascript_expansion(
  :rollcall => [ "rollcall/script_config" ])
ActionView::Helpers::AssetTagHelper.register_stylesheet_expansion(
  :rollcall => [ "rollcall/rollcall" ])
