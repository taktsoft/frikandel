module Frikandel
  module LimitSessionLifetime
    extend ActiveSupport::Concern
    include SessionInvalidation

    included do
      if respond_to?(:before_action)
        append_before_action :validate_session_timestamp
      else
        append_before_filter :validate_session_timestamp
      end
    end

  private

    def validate_session_timestamp
      if session.key?(:ttl) && session.key?(:max_ttl) && (reached_ttl? || reached_max_ttl?)
        on_invalid_session
      elsif !session.key?(:ttl) || !session.key?(:max_ttl)
        reset_session
      else # session timestamp is valid
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
      session[:max_ttl] ||= Frikandel::Configuration.max_ttl.since
    end

    def reset_session
      super
      persist_session_timestamp
    end
  end
end
