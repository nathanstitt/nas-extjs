# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)


Gem::Specification.new do |s|
    s.name = "nas-extjs"
    s.version = "0.4.0"
    s.authors = ['Nathan Stitt']
    s.date    = "2013-02-01"
    s.description = "Collection of functions to make working with Extjs and rails work together better"
    s.email = "nathan@stitt.org"
    s.extra_rdoc_files = [
        "LICENSE.txt",
        "README.md"
    ]
    s.files    = `git ls-files`.split($/)
    s.homepage = "http://github.com/nathanstitt/nas-extjs"
    s.licenses = ["MIT"]
    s.require_paths = ["lib"]
    s.rubygems_version = "1.8.23"
    s.summary = "Controller and utilities to make Extjs and rails work together better"

    s.add_dependency 'bundler'
    s.add_dependency 'protected_attributes'

end
