app = App.find_by_name('rollcall')

Role.find_or_create_by_name_and_app_id("Rollcall",app.id){|r| r.attributes = {:user_role => true, public: true} }
Role.find_or_create_by_name_and_app_id("Admin",app.id){|r| r.attributes = {:user_role => false} }
Role.find_or_create_by_name_and_app_id("Epidemiologist",app.id){|r| r.attributes = {:user_role => true} }
Role.find_or_create_by_name_and_app_id("Health Officer",app.id){|r| r.attributes = {:user_role => true} }
Role.find_or_create_by_name_and_app_id("Nurse",app.id){|r| r.attributes = {:user_role => true} }
# TODO
# Integrate school selection into roles and/or user

# As part of the seed, set your dev user to as rollcall user, admin
u = User.find_by_email("cdubose@texashan.org")
u.role_memberships.create(
  :jurisdiction_id => Jurisdiction.find_by_name('Harris').id,
  :role_id         => Role.admin("rollcall").id
) if Role.admin("rollcall")
u.role_memberships.create(
  :jurisdiction_id => Jurisdiction.find_by_name('Harris').id,
  :role_id => Role.find_by_name('Rollcall').id
) if Role.find_by_name('Rollcall')
u.role_memberships.create(
  :jurisdiction_id => Jurisdiction.find_by_name('Texas').id,
  :role_id => Role.superadmin("rollcall").id
)
