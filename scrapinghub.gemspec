# -*- encoding: utf-8 -*-
require File.expand_path("../lib/scrapinghub/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "scrapinghub-client"
  s.version     = ScrapingHub::VERSION
  s.authors     = ["Abe Voelker"]
  s.email       = "abe@abevoelker.com"
  s.homepage    = "https://github.com/abevoelker/scrapinghub-client"
  s.summary     = %q{Ruby client for ScrapingHub API}
  s.description = %q{Ruby client for ScrapingHub API}
  s.license     = "MIT"

  s.require_paths = ["lib"]
  s.require_paths = [ "lib" ]
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec}/*`.split("\n")

  s.add_dependency "contracts"
  s.add_dependency "kleisli"
  s.add_dependency "httparty"

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "webmock"
  s.add_development_dependency "vcr"
end
