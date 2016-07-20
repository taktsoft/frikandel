require "rails_helper"
require "support/application_controller"


class BindSessionToIpAddressController < ApplicationController
  include Frikandel::BindSessionToIpAddress

  if respond_to?(:before_action)
    before_action :flash_alert_and_redirect_home, only: [:redirect_home]
  else
    before_filter :flash_alert_and_redirect_home, only: [:redirect_home]
  end

  def home
    if Rails::VERSION::MAJOR >= 5
      render plain: "bind test"
    else
      render text: "bind test"
    end
  end

  def redirect_home
  end

protected

  def flash_alert_and_redirect_home
    flash[:alert] = "alert test"
    redirect_to bind_session_to_ip_address_home_url
  end
end


RSpec.describe BindSessionToIpAddressController do
  context "requests" do
    it "writes current ip address to session" do
      expect(session[:ip_address]).to be_nil

      get :home

      expect(session[:ip_address]).to eql("0.0.0.0")
    end

    it "writes current ip address to session even on redirect in another before filter" do
      expect(session[:ip_address]).to be_nil

      simulate_redirect!(:redirect_home, :home)

      expect(session[:ip_address]).to eql("0.0.0.0")

      expect(flash).not_to be_empty
      expect(flash[:alert]).to eql("alert test")
    end

    it "raises an exception if session address and current ip address don't match" do
      session[:ip_address] = "1.2.3.4"
      expect(controller).to receive(:on_invalid_session)

      get :home
    end


    context "ip address isn't present in session" do
      it "resets the session and persists the ip address" do
        session[:user_id] = 4337
        session.delete(:ip_address)
        session[:ttl] = "SomeTTL"
        session[:max_ttl] = "SomeMaxTTL"

        expect(controller).to receive(:reset_session).and_call_original
        expect(controller).to receive(:persist_session_ip_address).and_call_original
        get :home

        expect(session[:user_id]).to be_blank
        expect(session[:ip_address]).to be_present
        expect(session[:ip_address]).to eql("0.0.0.0")
        expect(session[:ttl]).to be_blank
        expect(session[:max_ttl]).to be_blank
      end

      it "allows the request to be rendered as normal" do
        get :home

        expect(response.body).to eql("bind test")
      end
    end
  end


  context ".validate_session_ip_address" do
    it "calls on_invalid_session if ip address doesn't match with current" do
      session[:ip_address] = "1.3.3.7"

      expect(controller).to receive(:ip_address_match_with_current?).and_return(false)
      expect(controller).to receive(:on_invalid_session)

      controller.send(:validate_session_ip_address)
    end

    it "calls reset_session if ip address isn't persisted in session" do
      session.delete(:ip_address)

      expect(controller).not_to receive(:ip_address_match_with_current?)
      expect(controller).to receive(:reset_session)

      controller.send(:validate_session_ip_address)
    end

    it "calls persist_session_ip_address if validation passes" do
      session[:ip_address] = "1.3.3.7"

      expect(controller).to receive(:ip_address_match_with_current?).and_return(true)
      expect(controller).to receive(:persist_session_ip_address)

      controller.send(:validate_session_ip_address)
    end
  end


  context ".persist_session_ip_address" do
    it "sets the current ip address in session on key ip_address" do
      expect {
        expect(controller).to receive(:current_ip_address).and_return("1.3.3.7")
        controller.send(:persist_session_ip_address)
      }.to change {
        session[:ip_address]
      }.from(nil).to("1.3.3.7")
    end
  end


  context ".current_ip_address" do
    it "returns the remote_ip from request" do
      expect(request).to receive(:remote_ip).and_return(:request_remote_ip)

      expect(controller.send(:current_ip_address)).to eql(:request_remote_ip)
    end
  end


  context ".ip_address_match_with_current?" do
    it "compares ip address from session with the current ip address" do
      allow(controller).to receive(:current_ip_address).and_return("1.3.3.7")

      session[:ip_address] = "1.3.3.7"

      expect(controller.send(:ip_address_match_with_current?)).to be_truthy

      session[:ip_address] = "7.3.3.1"

      expect(controller.send(:ip_address_match_with_current?)).to be_falsey
    end
  end


  context ".reset_session" do
    it "calls persist_session_ip_address" do
      expect(controller).to receive(:persist_session_ip_address).and_call_original
      controller.send(:reset_session)
    end
  end
end
