begin
  require "rspec/core/rake_task" 
  
  PLUGIN = "vendor/plugins/rollcall"
  
  namespace :spec do
    desc "Run the rollcall spec tests"
    RSpec::Core::RakeTask.new(:rollcall) do |spec|
      spec.pattern = "#{PLUGIN}/spec/**/*_spec.rb"
    end
  end
rescue LoadError
end
