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
      if session.key?(:ttl) && session.key?(:max_ttl) && (reached_ttl? || reached_max_ttl?)
        on_invalid_session
      elsif !session.key?(:ttl) || !session.key?(:max_ttl)
        reset_session_with_limit_session_lifetime_style
        persist_session_timestamp
      end
    end

    def reached_ttl?
      session[:ttl] < Frikandel::Configuration.ttl.ago
    end

    def reached_max_ttl?
      session[:max_ttl] < Time.now
    end

    def persist_session_timestamp
      session[:ttl] = Time.now
      session[:max_ttl] ||= Frikandel::Configuration.max_ttl.from_now
    end

    def reset_session_with_limit_session_lifetime_style
      unless @_frikandel_did_reset_session
        stored_ip_address = session[:ip_address]

        reset_session
        @_frikandel_did_reset_session = true

        session[:ip_address] = stored_ip_address if stored_ip_address.present?
      end
    end
  end
end
