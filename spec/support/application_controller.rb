
Rails.application.routes.draw do
  root to: "application#home"
  get "/limit_session_lifetime_home" => "limit_session_lifetime#home"
  get "/customized_controller_home" => "customized_on_invalid_session#home", as: :customized_controller_home
  get "/bind_session_to_ip_address_home" => "bind_session_to_ip_address#home"
  get "/combined_controller_home" => "combined#home"
end

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def home
    render text: "testing"
  end
end
