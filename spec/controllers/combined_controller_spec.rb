require "rails_helper"
require "support/application_controller"


class CombinedController < ApplicationController
  include Frikandel::LimitSessionLifetime
  include Frikandel::BindSessionToIpAddress

  if respond_to?(:before_action)
    before_action :flash_alert_and_redirect_home, only: [:redirect_home]
  else
    before_filter :flash_alert_and_redirect_home, only: [:redirect_home]
  end

  def home
    if Rails::VERSION::MAJOR >= 5
      render plain: "combined test"
    else
      render text: "combined test"
    end
  end

  def redirect_home
  end

protected

  def flash_alert_and_redirect_home
    flash[:alert] = "alert test"
    redirect_to combined_home_url
  end
end


RSpec.describe CombinedController do
  context "ttl nor ip isn't present in session" do
    it "resets the session and persists ip address, ttl & max_ttl" do
      session[:user_id] = 4337

      get :home

      expect(session[:user_id]).to be_blank
      expect(session[:ip_address]).to be_present
      expect(session[:ttl]).to be_present
      expect(session[:max_ttl]).to be_present
    end

    it "allows the request to be rendered as normal" do
      get :home

      expect(response.body).to eql("combined test")
    end

    it "persists ttl, max_ttl and ip even on redirect in another before filter" do
      expect(session[:ip_address]).to be_nil
      expect(session[:ttl]).to be_nil
      expect(session[:max_ttl]).to be_nil

      simulate_redirect!(:redirect_home, :home)

      expect(session[:ip_address]).to be_present
      expect(session[:ttl]).to be_present
      expect(session[:max_ttl]).to be_present

      expect(flash).not_to be_empty
      expect(flash[:alert]).to eql("alert test")
    end
  end


  context "ttl or ip isn't present in session" do
    it "resets the session and persists ip address, ttl & max_ttl if ip address is missing" do
      session[:user_id] = 4337
      session[:ttl] = last_ttl = Time.now
      session[:max_ttl] = last_max_ttl = Frikandel::Configuration.max_ttl.from_now

      get :home

      expect(session[:user_id]).to be_blank
      expect(session[:ip_address]).to be_present
      expect(session[:ttl]).to be_present
      expect(session[:ttl]).not_to eql(last_ttl)
      expect(session[:max_ttl]).to be_present
      expect(session[:max_ttl]).not_to eql(last_max_ttl)
    end

    it "resets the session and persists ip address, ttl & max_ttl if ttl is missing" do
      session[:user_id] = 4337
      session[:ip_address] = "0.0.0.0"
      session[:max_ttl] = last_max_ttl = Frikandel::Configuration.max_ttl.from_now

      get :home

      expect(session[:user_id]).to be_blank
      expect(session[:ip_address]).to be_present
      expect(session[:ip_address]).to eql("0.0.0.0")
      expect(session[:ttl]).to be_present
      expect(session[:max_ttl]).to be_present
      expect(session[:max_ttl]).not_to eql(last_max_ttl)
    end

    it "resets the session and persists ip address, ttl & max_ttl if max_ttl is missing" do
      session[:user_id] = 4337
      session[:ip_address] = "0.0.0.0"
      session[:ttl] = last_ttl = Time.now

      get :home

      expect(session[:user_id]).to be_blank
      expect(session[:ip_address]).to be_present
      expect(session[:ip_address]).to eql("0.0.0.0")
      expect(session[:ttl]).to be_present
      expect(session[:ttl]).not_to eql(last_ttl)
      expect(session[:max_ttl]).to be_present
    end
  end
end
