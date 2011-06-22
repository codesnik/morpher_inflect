# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "morpher_inflect/version"

Gem::Specification.new do |s|
  s.name        = "morpher_inflect"
  s.version     = MorpherInflect::VERSION
  s.authors     = ["Alexey Trofimenko", "Yaroslav Markin"]
  s.email       = ["codesnik@gmail.com"]
  s.homepage    = "http://github.com/codesnik/morpher_inflect/"
  s.summary     = "Morpher.ru webservice client (Russian language inflection)"
  s.description = "Morpher.ru inflections for russian proper and common nouns. Code based on yandex_inflect gem by Yaroslav Markin"

  s.rubyforge_project = "morpher_inflect"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.has_rdoc = true
  s.extra_rdoc_files = ["README.rdoc", "LICENSE", 'TODO', 'CHANGELOG']

  s.add_dependency "httparty"
  s.add_development_dependency "rspec", '2.6'
  s.add_development_dependency "rake"
end
