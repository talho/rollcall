Role.find_or_create_by_name_and_approval_required_and_user_role_and_application("Rollcall",true,false,'rollcall')
Role.find_or_create_by_name_and_approval_required_and_user_role_and_application("Admin",true,true,'rollcall')
Role.find_or_create_by_name_and_approval_required_and_user_role_and_application("Epidemiologist",true,true,'rollcall')
Role.find_or_create_by_name_and_approval_required_and_user_role_and_application("Health Officer",true,true,'rollcall')
Role.find_or_create_by_name_and_approval_required_and_user_role_and_application("Nurse",true,true,'rollcall')
# TODO
# Integrate school selection into roles and/or user
# 
#Role.find_or_create_by_name(:name => "SchoolGuest") { |role|
#  role.approval_required = true
#  role.user_role = false
#  role.application = 'rollcall'
#}
#Role.find_or_create_by_name(:name => "SchoolUser") { |role|
#  role.approval_required = true
#  role.user_role = false
#  role.application = 'rollcall'
#}
# As part of the seed, set your dev user to as rollcall user, admin
u = User.find_by_email("eddie@talho.org")
u.role_memberships.create(
  :jurisdiction_id => Jurisdiction.find_by_name('Harris').id,
  :role_id         => Role.admin("rollcall").id
) if Role.admin("rollcall")