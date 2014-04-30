Rails.application.routes.draw do
  root to: "application#home"
  get "/limit_session_lifetime_home" => "limit_session_lifetime#home", :as => :limit_session_lifetime_home
  get "/limit_session_lifetime_redirect_home" => "limit_session_lifetime#redirect_home"
  get "/bind_session_to_ip_address_home" => "bind_session_to_ip_address#home", :as => :bind_session_to_ip_address_home
  get "/bind_session_to_ip_address_redirect_home" => "bind_session_to_ip_address#redirect_home"
  get "/combined_controller_home" => "combined#home", :as => :combined_home
  get "/combined_controller_redirect_home" => "combined#redirect_home"
  get "/customized_controller_home" => "customized_on_invalid_session#home", :as => :customized_controller_home
end


class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def home
    render text: "testing"
  end
end
