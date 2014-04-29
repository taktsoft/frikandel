ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../dummy/config/environment", __FILE__)
require 'rspec/rails'
require 'pry'

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  config.before(:each) do
    Frikandel::Configuration.defaults!
  end
end


# some helper methods

def simulate_redirect!(from_action, to_action)
  get from_action.intern
  from_flash = request.flash # HACK for RAILS_VERSION=3.2.0

  controller.instance_variable_set(:@_frikandel_did_reset_session, nil) # reset state for redirect request

  get to_action.intern
  request.flash.update(from_flash.to_hash) # HACK for RAILS_VERSION=3.2.0
end

def flash
  request.flash
end
