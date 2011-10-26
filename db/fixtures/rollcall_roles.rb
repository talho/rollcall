Role.create(
  :name              => "Rollcall",
  :approval_required => true,
  :user_role         => false,
  :application       => 'rollcall'
)
Role.create(
  :name              => "Admin",
  :approval_required => true,
  :user_role         => true,
  :application       => 'rollcall'
)
Role.create(
  :name              => "Epidemiologist",
  :approval_required => true,
  :user_role         => true,
  :application       => 'rollcall'
)
Role.create(
  :name              => "Health Officer",
  :approval_required => true,
  :user_role         => true,
  :application       => 'rollcall'
)
Role.create(
  :name              => "Nurse",
  :approval_required => true,
  :user_role         => true,
  :application       => 'rollcall'
)
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