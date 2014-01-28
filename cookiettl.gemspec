# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cookiettl/version'

Gem::Specification.new do |spec|
  spec.name          = "cookiettl"
  spec.version       = Cookiettl::VERSION
  spec.authors       = ["Michael Berg"]
  spec.email         = ["berg@taktsoft.com"]
  spec.summary       = %q{This gem adds a ttl to the session cookie of your application.}
  spec.description   = ""
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = Dir["spec/**/*"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rails"
  spec.add_development_dependency "sqlite3" #FIXME
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "pry"
end
