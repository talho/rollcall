require 'cucumber/rake/task'

namespace :cucumber do
  Cucumber::Rake::Task.new({:rollcall => 'db:test:prepare'}, "Rollcall plugin features") do |t|
    t.cucumber_opts = "-r features " +
                      "-r vendor/plugins/rollcall/features/step_definitions " +
                      "vendor/plugins/rollcall/features"
    t.fork = true
    t.profile = 'default'
  end
end
