begin
  require "rspec/core/rake_task" 
  
  plugin = "vendor/plugins/rollcall"
  
  namespace :spec do
    desc "Run the rollcall spec tests"
    RSpec::Core::RakeTask.new(:rollcall) do |spec|
      spec.pattern = "#{plugin}/spec/**/*_spec.rb"
    end
  end
rescue LoadError
end
