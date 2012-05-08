When /^I generate "([^"]*)" rollcall report "([^"]*)" named "([^"]*)"$/ do |recipe, model, parameter|
  id = model.constantize.where('display_name'=>parameter).select(:id).map(&:id).first
  debugger
  criteria = {:recipe=>recipe,:params=>id}
  report = current_user.reports.create!(:recipe=>recipe,:criteria=>criteria,:incomplete=>true)
  Reporters::Reporter.new(:report_id=>report[:id]).perform
  @report = current_user.reports.find_by_id(id)
  raise unless @report && @report.rendering.path
end


