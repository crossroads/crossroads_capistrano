# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "crossroads_capistrano"
  s.version     = "1.3.61"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Steve Kenworthy", "Ben Tillman", "Nathan Broadbent"]
  s.email       = ["it_dept@crossroads.org.hk"]
  s.homepage    = "http://www.crossroads.org.hk"
  s.summary     = %q{Crossroads capistrano recipes}
  s.description = %q{A Crossroads Foundation collection of generic capistrano recipes.}

  s.rubyforge_project = "crossroads_capistrano"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end

