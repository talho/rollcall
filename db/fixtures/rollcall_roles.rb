Role.find_or_create_by_name_and_application("Rollcall",'rollcall'){|r| r.attributes = {:approval_required => false, :user_role => true,} }
Role.find_or_create_by_name_and_application("Admin",'rollcall'){|r| r.attributes = {:approval_required => true, :user_role => false,} }
Role.find_or_create_by_name_and_application("Epidemiologist",'rollcall'){|r| r.attributes = {:approval_required => true, :user_role => true,} }
Role.find_or_create_by_name_and_application("Health Officer",'rollcall'){|r| r.attributes = {:approval_required => true, :user_role => true,} }
Role.find_or_create_by_name_and_application("Nurse",'rollcall'){|r| r.attributes = {:approval_required => true, :user_role => true,} }
# TODO
# Integrate school selection into roles and/or user

# As part of the seed, set your dev user to as rollcall user, admin
u = User.find_by_email("eddie@talho.org")
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
