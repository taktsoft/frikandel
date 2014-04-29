module Frikandel
  module BindSessionToIpAddress
    extend ActiveSupport::Concern

    included do
      append_before_filter :validate_session_ip_address
      append_after_filter :persist_session_ip_address
    end

  private

    def validate_session_ip_address
      if session.key?(:ip_address) && !ip_address_match_with_current?
        on_invalid_session
      elsif !session.key?(:ip_address)
        reset_session_with_bind_session_to_ip_address_style
        persist_session_ip_address
      end
    end

    def persist_session_ip_address
      session[:ip_address] = current_ip_address
    end

    def current_ip_address
      request.remote_ip
    end

    def ip_address_match_with_current?
      session[:ip_address] == current_ip_address
    end

    def reset_session_with_bind_session_to_ip_address_style
      unless @_frikandel_did_reset_session
        stored_ttl = session[:ttl]
        stored_max_ttl = session[:max_ttl]

        reset_session
        @_frikandel_did_reset_session = true

        session[:ttl] = stored_ttl if stored_ttl.present?
        session[:max_ttl] = stored_max_ttl if stored_max_ttl.present?
      end
    end
  end
end
