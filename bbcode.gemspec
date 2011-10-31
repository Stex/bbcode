# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "bbcode/version"

Gem::Specification.new do |s|
	s.name        = "bbcode"
	s.version     = Bbcode::VERSION
	s.authors     = ["Toby Hinloopen"]
	s.email       = ["toby@kutcomputers.nl"]
	s.homepage    = ""
	s.summary     = %q{BBCode parser}
	s.description = %q{BBCode parser}

	s.rubyforge_project = "bbcode"

	s.add_development_dependency "rspec", "~> 2.6"
	s.add_dependency "activesupport", "~> 3.0.9"
	s.add_dependency "actionpack", "~> 3.0.9"
	s.add_dependency "i18n", "~> 0.5.0"

	s.files         = `git ls-files`.split("\n")
	s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
	s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
	s.require_paths = ["lib"]
end
