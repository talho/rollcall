begin
  require 'cucumber/rake/task'

  ENV["RAILS_ENV"] ||= "cucumber"
  
  namespace :cucumber do
    desc = "Rollcall plugin, add any cmd args after --"
    Cucumber::Rake::Task.new(:rollcall, desc) do |t|
      t.cucumber_opts = "RAILS_ENV=cucumber -r features " +
                       # "-r vendor/extensions/rollcall/spec/factories.rb " +
                        "-r #{File.join(File.dirname(__FILE__), '..', '..')}/features/step_definitions " +
                        " #{ARGV[1..-1].join(" ") if ARGV[1..-1]}" +
                        # add all rollcall features if none are passed in
                        (ARGV.length <= 1 ? "#{File.join(File.dirname(__FILE__), '..', '..')}/features" : "")
      t.fork = true
      t.profile = 'default'
    end
  end
rescue LoadError
  # to catch if cucumber is not installed, as in production
end
