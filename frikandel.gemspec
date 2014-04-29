# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'frikandel/version'

Gem::Specification.new do |spec|
  spec.name          = "frikandel"
  spec.version       = Frikandel::VERSION
  spec.authors       = ["Taktsoft"]
  spec.email         = ["developers@taktsoft.com"]
  spec.summary       = %q{This gem adds a ttl to the session cookie of your application.}
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/taktsoft/frikandel"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = Dir["spec/**/*"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "sqlite3" unless RUBY_PLATFORM == 'java'
  spec.add_development_dependency "jdbc-sqlite3" if RUBY_PLATFORM == 'java'
  spec.add_development_dependency "activerecord-jdbcsqlite3-adapter" if RUBY_PLATFORM == 'java'
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "pry"

  spec.add_dependency "rails", [">= 3.2.0", "<= 4.1"]
end
