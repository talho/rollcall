When /^I generate "([^"]*)" rollcall report on "([^"]*)" named "([^"]*)"$/ do |recipe, model, parameter|
  where = 'display_name'
  id = model.constantize.where(where=>parameter).pluck(:id).first
  criteria = {:recipe=>recipe,:model=>model,:method=>:find_by_id,:params=>id}
  report = current_user.reports.create!(:recipe=>recipe,:criteria=>criteria,:incomplete=>true)
  Reporters::Reporter.new(:report_id=>report[:id]).perform
  @report = current_user.reports.find_by_id(id)
  raise unless @report && @report.rendering.path
end
