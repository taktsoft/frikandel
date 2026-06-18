ENV['RAILS_ENV'] ||= 'test'
require File.expand_path("../dummy/config/environment", __FILE__)
# Prevent accidental runs against production.
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'spec_helper'
require 'rspec/rails'

RSpec.configure do |config|
  # Enables `get`/`post` etc. in specs under spec/controllers.
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
end

# some helper methods

def simulate_redirect!(from_action, to_action)
  get from_action.intern
  from_flash = request.flash

  controller.instance_variable_set(:@_frikandel_did_reset_session, nil) # reset state for redirect request

  get to_action.intern
  request.flash.update(from_flash.to_hash)
end

def flash
  request.flash
end
