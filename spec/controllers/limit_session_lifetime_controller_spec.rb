require "spec_helper"
require "support/application_controller"

class LimitSessionLifetimeController < ApplicationController
  include Frikandel::LimitSessionLifetime

  def home
    render text: "ttl test"
  end
end

describe LimitSessionLifetimeController do
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
    request.session[:ttl] = (Frikandel::Configuration.ttl + 1.minute).seconds.ago
    get :home

    session[:user_id].should be_blank
  end

  it "destroys the session after SESSION_MAX_TTL" do
    get :home
    session[:user_id] = 3337

    request.session[:max_ttl] = 1.minute.ago
    get :home

    session[:user_id].should be_blank
  end
  it "is configurable" do
    old_value = Frikandel::Configuration.ttl
    Frikandel::Configuration.ttl = 1.minute
    get :home
    session[:ttl] = 30.minutes.ago
    session[:user_id] = 5337

    get :home
    session[:user_id].should be_blank

    Frikandel::Configuration.ttl = old_value
  end

  context "ttl isn't present in session" do
    it "resets the session" do
      session[:user_id] = 4337
      get :home

      session[:user_id].should be_blank
    end

    it "allows the request to be rendered as normal" do
      get :home

      response.body.should eql("ttl test")
    end
  end
end
