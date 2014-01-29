
Rails.application.routes.draw do
  get "/home" => "application#home", as: :root
  get "/customized_controller_home" => "customized_on_expired_cookie#home", as: :customized_controller_home
end


class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def home
    render text: "testing"
  end
end
