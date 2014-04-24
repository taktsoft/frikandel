module Frikandel
  module LimitSessionLifetime
    extend ActiveSupport::Concern

    included do
      append_before_filter :validate_session_timestamp
      append_after_filter :persist_session_timestamp
    end

  private

    def validate_session_timestamp
      if session.key?(:ttl) && session.key?(:max_ttl) && (session[:ttl] < Frikandel::Configuration.ttl.ago || session[:max_ttl] < Time.now)
        on_expired_session
      end
    end

    def persist_session_timestamp
      session[:ttl] = Time.now
      session[:max_ttl] ||= Frikandel::Configuration.max_ttl.from_now
    end

    def on_expired_session
      reset_session
      redirect_to root_path
    end
    alias original_on_expired_session on_expired_session
  end
end
