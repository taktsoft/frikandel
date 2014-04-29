require "spec_helper"
require "support/application_controller"


class BindSessionToIpAddressController < ApplicationController
  include Frikandel::BindSessionToIpAddress

  before_filter :flash_alert_and_redirect_home, only: [:redirect_home]

  def home
    render text: "bind test"
  end

  def redirect_home
  end

protected

  def flash_alert_and_redirect_home
    flash[:alert] = "alert test"
    redirect_to bind_session_to_ip_address_home_url
  end
end


describe BindSessionToIpAddressController do
  it "writes current ip address to session" do
    expect(session[:ip_address]).to be_nil

    get :home

    expect(session[:ip_address]).to eql("0.0.0.0")
  end

  it "writes current ip address to session even on redirect in another before filter" do
    expect(session[:ip_address]).to be_nil

    simulate_redirect!(:redirect_home, :home)

    expect(session[:ip_address]).to eql("0.0.0.0")

    flash.should be_key(:alert)
    flash[:alert].should eql("alert test")
  end

  it "raises an exception if session address and current ip address don't match" do
    session[:ip_address] = "1.2.3.4"
    controller.should_receive(:on_invalid_session)

    get :home
  end


  context "ip address isn't present in session" do
    it "resets the session, but keeps ttl and max_ttl" do
      session[:user_id] = 4337
      session.delete(:ip_address)
      session[:ttl] = "SomeTTL"
      session[:max_ttl] = "SomeMaxTTL"

      get :home

      session[:user_id].should be_blank
      session[:ip_address].should be_present
      session[:ttl].should eql("SomeTTL")
      session[:max_ttl].should eql("SomeMaxTTL")
    end

    it "allows the request to be rendered as normal" do
      get :home

      response.body.should eql("bind test")
    end
  end
end
