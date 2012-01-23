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

# Register the plugin expansion in the $expansion_list global variable
$expansion_list = [] unless defined?($expansion_list)
$expansion_list.push(:rollcall) unless $expansion_list.index(:rollcall)


# Build the menu in the $menu_config global variable
$menu_config = {} unless defined?($menu_config)
$menu_config[:rollcall] = <<EOF
  nav = "{name: 'Rollcall', items:[
    {name: 'ADST', tab:{id: 'rollcall_adst', title:'Rollcall ADST', url:'', initializer: 'Talho.Rollcall.ADST'}},
    {name: 'Nurse Assistant', tab:{id: 'rollcall_nurse_assistant', title:'Nurse Assistant', url:'', initializer: 'Talho.Rollcall.NurseAssistant'}},
    {name: 'Schools', tab:{id: 'rollcall_schools', title:'Rollcall Schools', url:'', initializer: 'Talho.Rollcall.Schools'}}"
  if current_user.is_rollcall_admin?
    nav += ",
      {name: 'Admin', items:[
        {name: 'Users', tab:{id: 'rollcall_users', title:'Rollcall Users', url:'', initializer: 'Talho.Rollcall.Users'}}
      ]}"
  end
  nav += "]}"
EOF

begin
  $public_roles = [] unless defined?($public_roles)
  r = Role.find_by_name_and_application('Rollcall', 'rollcall')
  $public_roles << r.id unless r.nil?
rescue
end

# Register any required javascript or stylesheet files with the appropriate
# rails expansion helper
ActionView::Helpers::AssetTagHelper.register_javascript_expansion(
  :rollcall => [ "rollcall/script_config" ])
ActionView::Helpers::AssetTagHelper.register_stylesheet_expansion(
  :rollcall => [ "rollcall/rollcall" ])
