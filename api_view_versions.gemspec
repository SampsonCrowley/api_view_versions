# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "api_view_versions/version"

Gem::Specification.new do |s|
  s.name        = "api_view_versions"
  s.version     = ApiViewVersions::VERSION
  s.license     = 'MIT'
  s.authors     = ["Sampson Crowley"]
  s.email       = ["sampsoncrowley@gmail.com"]
  s.homepage    = "http://SampsonCrowley.github.io/api_view_versions"
  s.summary     = %q{An extremely opinionated, slimmed and focused rewrite of versioncake}
  s.description = %q{Render versioned views automagically based on the clients requested version.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.required_ruby_version = '>= 2.6.6'

  s.add_dependency('actionpack',    '> 4.1')
  s.add_dependency('activesupport', '> 4.1')
  s.add_dependency('railties',      '> 4.1')
  s.add_dependency('tzinfo',        '> 1.2')

  s.add_development_dependency 'appraisal', '~> 2.2'
  s.add_development_dependency 'coveralls', '~> 0.8'
  s.add_development_dependency 'rake', '> 12.0'

  s.add_development_dependency 'rspec', '~> 3.6'
  s.add_development_dependency 'rspec-rails', '~> 3.6'
  s.add_development_dependency 'jbuilder', '> 2.8'
end
