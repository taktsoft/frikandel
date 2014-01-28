require "cookiettl/version"

module Cookiettl
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

    SESSION_MAX_TTL ||= 24.hours
    SESSION_TTL ||= 2.hours

    def validate_session_timestamp
      if session.key?(:ttl) && (session[:ttl] < SESSION_TTL.ago || session[:ttl] < SESSION_MAX_TTL.ago)
        reset_session
        redirect_to root_path
      end
    end

    def persist_session_timestamp
      session[:ttl] = Time.now
      session[:max_ttl] ||= SESSION_MAX_TTL.from_now
    end
  end
end
