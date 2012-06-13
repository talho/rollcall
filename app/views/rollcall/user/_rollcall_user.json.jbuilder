json.(user, :display_name, :first_name, :last_name, :email, :schools, :school_districts)
json.user_id user.id
json.photo user.photo.url(:tiny)

json.role_memberships user.role_memberships.map{|rm| "#{rm.role.name} in #{rm.jurisdiction.name}"}
json.role_requests current_user.is_admin? ? user.role_requests.unapproved.map{|rq| "#{rq.role.name} in #{rq.jurisdiction.name}"} 
  : []