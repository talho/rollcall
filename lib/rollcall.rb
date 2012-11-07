
# Tell the main app that this extension exists
$extensions = [] unless defined?($extensions)
$extensions << :rollcall

# Build the menu in the $menu_config global variable
$menu_config = {} unless defined?($menu_config)
$menu_config[:rollcall] = <<EOF
  if current_user.has_non_public_role?('rollcall')
    nav = "{name: 'Rollcall', items:[
      {name: 'ADST', tab:{id: 'rollcall_adst', title:'Rollcall ADST', url:'', initializer: 'Talho.Rollcall.ADST'}},
      {name: 'Nurse Assistant', tab:{id: 'rollcall_nurse_assistant', title:'Nurse Assistant', url:'', initializer: 'Talho.Rollcall.NurseAssistant'}},
      {name: 'Schools', tab:{id: 'rollcall_schools', title:'Rollcall Schools', url:'', initializer: 'Talho.Rollcall.Schools'}}"
    if current_user.is_rollcall_admin?
      nav += ",
        {name: 'Admin', items:[
          {name: 'Users', tab:{id: 'rollcall_users', title:'Rollcall Users', url:'', initializer: 'Talho.Rollcall.Users'}}"      
      nav += ",{name: 'Status', tab:{id: 'rollcall_status', title:'Rollcall Status', url:'', initializer: 'Talho.Rollcall.Status'}}" if current_user.is_super_admin?("rollcall")      
    end
      nav += " ]}"
    nav += "]}"
  end
EOF

$extensions_css = {} unless defined?($extensions_css)
$extensions_css[:rollcall] = [ "rollcall/rollcall.css" ]
$extensions_js = {} unless defined?($extensions_js)
$extensions_js[:rollcall] = [ "rollcall/script_config.js" ]
  
module Rollcall
  module Models
    autoload :Jurisdiction, 'rollcall/models/jurisdiction'
    autoload :User, 'rollcall/models/user'
    autoload :DocumentMailer, 'rollcall/models/document_mailer'
  end
end

if defined? BDRB_CONFIG
  $LOAD_PATH.unshift(File.join(File.dirname(__FILE__),"workers"))
end

require 'rollcall/engine'

Dir[File.dirname(__FILE__) + '/import/*.rb'].each {|file| require file }