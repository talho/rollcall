# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rollcall/version"

Gem::Specification.new do |s|
  s.name        = "rollcall"
  s.version     = Rollcall::VERSION
  s.authors     = ["Eddie Gomez"]
  s.email       = ["eddie@talho.org"]
  s.homepage    = ""
  s.summary     = %q{}
  s.description = %q{}

  s.rubyforge_project = "rollcall"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
