require File.expand_path('../boot', __FILE__)

# Only the frameworks the gem actually needs.
require "action_controller/railtie"

Bundler.require(*Rails.groups)
require "frikandel"

module Dummy
  class Application < Rails::Application
    config.load_defaults Rails::VERSION::STRING.to_f
    config.eager_load = false

    # Static secret for the test suite only — not a real credential.
    config.secret_key_base = "dummy_secret_key_base_for_the_frikandel_test_suite_only"
  end
end
