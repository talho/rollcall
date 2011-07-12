begin
  require 'cucumber/rake/task'

  namespace :cucumber do
    desc = "Rollcall plugin, add any cmd args after --"
    #Cucumber::Rake::Task.new({:rollcall => 'db:test:prepare'}, desc) do |t|
    Cucumber::Rake::Task.new(:rollcall, desc) do |t|
      t.cucumber_opts = "RAILS_ENV=cucumber -r features " +
                       # "-r vendor/plugins/rollcall/spec/factories.rb " +
                        "-r vendor/plugins/rollcall/features/step_definitions " +
                        " #{ARGV[1..-1].join(" ") if ARGV[1..-1]}" +
                        # add all rollcall features if none are passed in
                        (ARGV.grep(/vendor/).empty? ? "vendor/plugins/rollcall/features" : "")
      t.fork = true
      t.profile = 'default'
    end
  end
rescue LoadError
  # to catch if cucumber is not installed, as in production
end
