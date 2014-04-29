require "spec_helper"
require "support/application_controller"


class LimitSessionLifetimeController < ApplicationController
  include Frikandel::LimitSessionLifetime

  before_filter :flash_alert_and_redirect_home, only: [:redirect_home]

  def home
    render text: "ttl test"
  end

  def redirect_home
  end

protected

  def flash_alert_and_redirect_home
    flash[:alert] = "alert test"
    redirect_to limit_session_lifetime_home_url
  end
end


describe LimitSessionLifetimeController do
  it "writes ttl and max_ttl to session" do
    expect(session[:ttl]).to be_nil
    expect(session[:max_ttl]).to be_nil

    get :home

    expect(session[:ttl]).to be_a(Time)
    expect(session[:max_ttl]).to be_a(Time)
  end

  it "writes ttl and max_ttl to session even on redirect in another before filter" do
    expect(session[:ttl]).to be_nil
    expect(session[:max_ttl]).to be_nil

    simulate_redirect!(:redirect_home, :home)

    expect(session[:ttl]).to be_a(Time)
    expect(session[:max_ttl]).to be_a(Time)

    flash.should be_key(:alert)
    flash[:alert].should eql("alert test")
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
    session[:ttl] = (Frikandel::Configuration.ttl + 1.minute).seconds.ago

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
    Frikandel::Configuration.ttl = 1.minute
    get :home

    session[:ttl] = 30.minutes.ago
    session[:user_id] = 5337

    get :home

    session[:user_id].should be_blank
  end


  context "ttl isn't present in session" do
    it "resets the session, but keeps ip address" do
      session[:user_id] = 4337
      session[:ip_address] = "SomeIP"
      session.delete(:ttl)
      session[:max_ttl] = "SomeMaxTTL"

      get :home

      session[:user_id].should be_blank
      session[:ip_address].should eql("SomeIP")
      session[:ttl].should be_present
      session[:max_ttl].should be_present
      session[:max_ttl].should_not eql("SomeMaxTTL")
    end

    it "allows the request to be rendered as normal" do
      get :home

      response.body.should eql("ttl test")
    end
  end


  context "max_ttl isn't present in session" do
    it "resets the session, but keeps ip address" do
      session[:user_id] = 4337
      session[:ip_address] = "SomeIP"
      session[:ttl] = "SomeTTL"
      session.delete(:max_ttl)

      get :home

      session[:user_id].should be_blank
      session[:ip_address].should eql("SomeIP")
      session[:ttl].should be_present
      session[:ttl].should_not eql("SomeTTL")
      session[:max_ttl].should be_present
    end

    it "allows the request to be rendered as normal" do
      get :home

      response.body.should eql("ttl test")
    end
  end


  context "ttl and max_ttl isn't present in session" do
    it "resets the session, but keeps ip address" do
      session[:user_id] = 4337
      session[:ip_address] = "SomeIP"

      get :home

      session[:user_id].should be_blank
      session[:ip_address].should eql("SomeIP")
      session[:ttl].should be_present
      session[:max_ttl].should be_present
    end

    it "allows the request to be rendered as normal" do
      get :home

      response.body.should eql("ttl test")
    end
  end
end
