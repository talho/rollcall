
module Rollcall
  class Engine < Rails::Engine
    
    config.after_initialize do 
      begin
        $public_roles = [] unless defined?($public_roles)
        r = Role.find_by_name_and_application('Rollcall', 'rollcall')
        $public_roles << r.id unless r.nil?
      rescue
      end
    end
    
    config.to_prepare do
      ::Jurisdiction.send(:include, Models::Jurisdiction)
      ::User.send(:include, Models::User)
      ::DocumentMailer.send(:include, Models::DocumentMailer)
      Rollcall::ILIReport
    end
    
  end
end