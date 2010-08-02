require 'spec/rake/spectask'

PLUGIN = "vendor/plugins/rollcall"

namespace :spec do
  desc "Run the rollcall spec tests"
  Spec::Rake::SpecTask.new(:rollcall) do |t|
    t.spec_files = FileList["#{PLUGIN}/spec/**/*_spec.rb"]
  end
end
