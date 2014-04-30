module Frikandel
  module BindSessionToIpAddress
    extend ActiveSupport::Concern

    included do
      append_before_filter :validate_session_ip_address
    end

  private

    def validate_session_ip_address
      if session.key?(:ip_address) && !ip_address_match_with_current?
        on_invalid_session
      elsif !session.key?(:ip_address)
        reset_session
      else # session ip address is valid
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

    def reset_session
      super
      persist_session_ip_address
    end
  end
end
