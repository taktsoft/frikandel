require "spec_helper"

Rails.application.routes.draw do
  get "/home" => "application#home", as: :root
end

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def home
    render text: "testing"
  end
end

class User; end

describe ApplicationController do
  before :each do
    controller.stub(:current_user?).and_return(true)
    controller.stub(:current_user).and_return(User.new)
  end

  it "holds the session for at least .1 seconds" do
    get :home
    session[:user_id] = 1337
    sleep 0.1
    get :home

    session[:user_id].should be_present
    session[:user_id].should eq 1337
  end

  it "destroys the session after SESSION_TTL" do
    get :home
    session[:user_id] = 2337

    request.session[:ttl] = (Cookiettl::Filter::SESSION_TTL + 1.minute).seconds.ago
    get :home

    session[:user_id].should be_blank
  end

  it "destroys the session after SESSION_MAX_TTL" do
    get :home
    session[:user_id] = 3337

    request.session[:ttl] = (Cookiettl::Filter::SESSION_MAX_TTL + 1.minute).seconds.ago
    get :home

    session[:user_id].should be_blank
  end

  it "works when there was no session in the request" do
    get :home
    session[:user_id] = 4337
    request.session = nil
    get :home

    session[:user_id].should be_blank
  end

  it "is configurable" do
    old_value = Cookiettl::Filter::SESSION_MAX_TTL

    Cookiettl::Filter::SESSION_MAX_TTL = 1.minute
    get :home
    session[:ttl] = 30.minutes.ago
    session[:user_id] = 5337

    get :home
    session[:user_id].should be_blank

    Cookiettl::Filter::SESSION_MAX_TTL = old_value
  end
end
