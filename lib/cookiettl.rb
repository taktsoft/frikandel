require "cookiettl/version"

module Cookiettl
  class Configuration
    include Singleton
    extend SingleForwardable
    attr_accessor :ttl, :max_ttl

    def_delegators :instance, :ttl, :ttl=, :max_ttl, :max_ttl=
  end

  class Railtie < Rails::Railtie
    initializer "cookie-ttl.add_filter_to_application_controller" do
      ActiveSupport.on_load(:action_controller) do
        ActionController::Base.send(:include, Filter)
      end
    end
  end

  module Filter
    extend ActiveSupport::Concern

    included do
      append_before_filter :validate_session_timestamp
      append_after_filter :persist_session_timestamp
    end

    Cookiettl::Configuration.max_ttl ||= 24.hours
    Cookiettl::Configuration.ttl ||= 2.hours

    def validate_session_timestamp
      if session.key?(:ttl) && session.key?(:max_ttl) && (session[:ttl] < Cookiettl::Configuration.ttl.ago || session[:max_ttl] < Time.now)
        on_expired_cookie
      end
    end

    def persist_session_timestamp
      session[:ttl] = Time.now
      session[:max_ttl] ||= Cookiettl::Configuration.max_ttl.from_now
    end

    def on_expired_cookie
      reset_session
      redirect_to root_path
    end
    alias original_on_expired_cookie on_expired_cookie
  end
end
