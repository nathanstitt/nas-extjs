# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "nas-extjs"
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Nathan Stitt"]
<<<<<<< HEAD
  s.date = "2013-01-05"
=======
  s.date = "2013-01-04"
>>>>>>> 1a48673e7d4c7917b3cba1d3f48e4f76629dcd9f
  s.description = "Collection of functions to make working with Extjs and rails work together better"
  s.email = "nathan@stitt.org"
  s.extra_rdoc_files = [
    "LICENSE.txt",
<<<<<<< HEAD
=======
    "README.md",
>>>>>>> 1a48673e7d4c7917b3cba1d3f48e4f76629dcd9f
    "README.rdoc"
  ]
  s.files = [
    ".document",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
<<<<<<< HEAD
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "lib/generators/nas_extjs/install/install_generator.rb",
    "lib/nas-extjs.rb",
    "lib/nas-extjs/controller.rb",
    "nas-extjs.gemspec",
=======
    "README.md",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "lib/nas-extjs.rb",
    "lib/nas-extjs/controller.rb",
>>>>>>> 1a48673e7d4c7917b3cba1d3f48e4f76629dcd9f
    "test/helper.rb",
    "test/test_nas-extjs.rb"
  ]
  s.homepage = "http://github.com/nathanstitt/nas-extjs"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
<<<<<<< HEAD
  s.summary = "Controller and utilities to make Extjs and rails work together better"
=======
  s.summary = "Collection of functions to make working with Extjs and rails work together better"
>>>>>>> 1a48673e7d4c7917b3cba1d3f48e4f76629dcd9f

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rdoc>, [">= 0"])
      s.add_development_dependency(%q<bundler>, [">= 0"])
      s.add_development_dependency(%q<jeweler>, [">= 0"])
    else
      s.add_dependency(%q<rdoc>, [">= 0"])
      s.add_dependency(%q<bundler>, [">= 0"])
      s.add_dependency(%q<jeweler>, [">= 0"])
    end
  else
    s.add_dependency(%q<rdoc>, [">= 0"])
    s.add_dependency(%q<bundler>, [">= 0"])
    s.add_dependency(%q<jeweler>, [">= 0"])
  end
end

