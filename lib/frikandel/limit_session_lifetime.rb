module Frikandel
  module LimitSessionLifetime
    extend ActiveSupport::Concern
    include SessionInvalidation

    included do
      append_before_filter :validate_session_timestamp
      append_after_filter :persist_session_timestamp
    end

  private

    def validate_session_timestamp
      if session.key?(:ttl) && session.key?(:max_ttl) && (session[:ttl] < Frikandel::Configuration.ttl.ago || session[:max_ttl] < Time.now)
        on_invalid_session
      end
    end

    def persist_session_timestamp
      session[:ttl] = Time.now
      session[:max_ttl] ||= Frikandel::Configuration.max_ttl.from_now
    end
  end
end
