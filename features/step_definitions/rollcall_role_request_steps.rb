Given /^I maliciously request the rollcall role "([^"]*)" in "([^"]*)"$/ do |role, jur|
  rhashes = []
  current_user.role_memberships.each{|rm|
    rid = rm.role_id
    jid = rm.jurisdiction_id
    rhashes.push({:id=>rm.id, :role_id=>rid, :jurisdiction_id=>jid,:rname=>Role.find(rid).name, :jname=>Jurisdiction.find(jid).name, :state=>'unchanged', :type=> 'role' })
  }
  role = Role.find_by_name_and_application(role, 'rollcall')
  jur  = Jurisdiction.find_by_name(jur)
  rhashes.push({:id=>-1, :role_id=>role.id, :jurisdiction_id=>jur.id, :rname=> role.name, :jname=> jur.name, :state=>"new"})
  script = "xhr = new XMLHttpRequest(); " +
          "xhr.open('PUT','/users/#{current_user.id}/profile.json');" +
          "xhr.setRequestHeader('Content-Type','application/x-www-form-urlencoded');" +
          "xhr.send( #{ "'user%5Brq%5D=" + CGI.escape(rhashes.to_json) + "'" });"
  page.execute_script(script)
end