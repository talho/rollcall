require 'cucumber/rake/task'

ENV["RAILS_ENV"] ||= "cucumber"

namespace :cucumber do
  desc = "Rollcall plugin, add any cmd args after --"
  Cucumber::Rake::Task.new({:rollcall => 'db:test:prepare'}, desc) do |t|
    t.cucumber_opts = "-r features " +
                      "-r vendor/plugins/rollcall/features/step_definitions " +
                      " #{ARGV[1..-1].join(" ") if ARGV[1..-1]}" +
                      # add all rollcall features if none are passed in
                      (ARGV.grep(/^vendor/).empty? ? "vendor/plugins/rollcall/features" : "")
    t.fork = true
    t.profile = 'default'
  end
end
