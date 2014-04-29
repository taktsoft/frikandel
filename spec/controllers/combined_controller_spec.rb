require "spec_helper"
require "support/application_controller"


class CombinedController < ApplicationController
  include Frikandel::LimitSessionLifetime
  include Frikandel::BindSessionToIpAddress

  before_filter :flash_alert_and_redirect_home, only: [:redirect_home]

  def home
    render text: "combined test"
  end

  def redirect_home
  end

protected

  def flash_alert_and_redirect_home
    flash[:alert] = "alert test"
    redirect_to combined_home_url
  end
end


describe CombinedController do
  context "ttl nor ip isn't present in session" do
    it "resets the session" do
      session[:user_id] = 4337

      get :home

      session[:user_id].should be_blank
      session[:ttl].should be_present
      session[:max_ttl].should be_present
      session[:ip_address].should be_present
    end

    it "resets the session only once" do
      controller.should_receive(:reset_session).exactly(:once)

      get :home
    end

    it "allows the request to be rendered as normal" do
      get :home

      response.body.should eql("combined test")
    end

    it "persists ttl, max_ttl and ip even on redirect in another before filter" do
      session[:ttl].should be_nil
      session[:max_ttl].should be_nil
      session[:ip_address].should be_nil

      simulate_redirect!(:redirect_home, :home)

      session[:ttl].should be_present
      session[:max_ttl].should be_present
      session[:ip_address].should be_present

      flash.should be_key(:alert)
      flash[:alert].should eql("alert test")
    end
  end


  context "ttl or ip isn't present in session" do
    it "resets the session if ip address is missing" do
      session[:user_id] = 4337
      session[:ttl] = last_ttl = Time.now
      session[:max_ttl] = last_max_ttl = Frikandel::Configuration.max_ttl.from_now

      get :home

      session[:user_id].should be_blank
      session[:ttl].should be_present
      session[:ttl].should_not eql(last_ttl) # reseted by limit_session_lifetime_controller
      session[:max_ttl].should be_present
      session[:max_ttl].should eql(last_max_ttl) # kept by bind_session_to_ip_address_controller
      session[:ip_address].should be_present
    end

    it "resets the session if ttl is missing" do
      session[:user_id] = 4337
      session[:ip_address] = "0.0.0.0"
      session[:max_ttl] = last_max_ttl = Frikandel::Configuration.max_ttl.from_now

      get :home

      session[:user_id].should be_blank
      session[:ttl].should be_present
      session[:max_ttl].should be_present
      session[:max_ttl].should_not eql(last_max_ttl)
      session[:ip_address].should be_present
      session[:ip_address].should eql("0.0.0.0")
    end

    it "resets the session if max_ttl is missing" do
      session[:user_id] = 4337
      session[:ip_address] = "0.0.0.0"
      session[:ttl] = last_ttl = Time.now

      get :home

      session[:user_id].should be_blank
      session[:ttl].should be_present
      session[:ttl].should_not eql(last_ttl)
      session[:max_ttl].should be_present
      session[:ip_address].should be_present
      session[:ip_address].should eql("0.0.0.0")
    end
  end
end
