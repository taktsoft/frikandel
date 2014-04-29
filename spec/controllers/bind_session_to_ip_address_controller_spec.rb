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

      flash.should be_key(:alert)
      flash[:alert].should eql("alert test")
    end

    it "raises an exception if session address and current ip address don't match" do
      session[:ip_address] = "1.2.3.4"
      controller.should_receive(:on_invalid_session)

      get :home
    end


    context "ip address isn't present in session" do
      it "resets the session (if frikandel didn't limit session lifetime)" do
        session[:user_id] = 4337
        session.delete(:ip_address)
        session[:ttl] = "SomeTTL"
        session[:max_ttl] = "SomeMaxTTL"

        controller.stub(:frikandel_did_limit_session_lifetime?).and_return(false)
        get :home

        session[:user_id].should be_blank
        session[:ip_address].should be_present
        session[:ttl].should be_blank
        session[:max_ttl].should be_blank
      end

      it "resets the session, but restores ttl and max_ttl if frikandel did limit session lifetime" do
        session[:user_id] = 4337
        session.delete(:ip_address)
        session[:ttl] = "SomeTTL"
        session[:max_ttl] = "SomeMaxTTL"

        controller.stub(:frikandel_did_limit_session_lifetime?).and_return(true)
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


  context ".validate_session_ip_address" do
    it "sets instance variable @_frikandel_did_validate_session_ip_address to true on pass" do
      controller.send(:persist_session_ip_address) # to let the validation pass

      expect {
        controller.should_not_receive(:on_invalid_session)
        controller.should_not_receive(:reset_session_with_bind_session_to_ip_address_style)
        controller.should_not_receive(:persist_session_ip_address)

        controller.send(:validate_session_ip_address)
      }.to change {
        controller.instance_variable_get(:@_frikandel_did_validate_session_ip_address)
      }.from(nil).to(true)
    end
  end


  context ".persist_session_ip_address" do
    it "sets instance variable @_frikandel_did_persist_session_ip_address to true" do
      expect {
        controller.send(:persist_session_ip_address)
      }.to change {
        controller.instance_variable_get(:@_frikandel_did_persist_session_ip_address)
      }.from(nil).to(true)
    end
  end


  context ".reset_session_with_bind_session_to_ip_address_style" do
    it "sets instance variable @_frikandel_did_reset_session to true" do
      session[:ttl] = "SomeTTL"
      session[:max_ttl] = "SomeMaxTTL"

      expect {
        controller.send(:reset_session_with_bind_session_to_ip_address_style)
      }.to change {
        controller.instance_variable_get(:@_frikandel_did_reset_session)
      }.from(nil).to(true)

      session[:ttl].should be_nil
      session[:max_ttl].should be_nil
    end

    it "resets session only if instance variable @_frikandel_did_reset_session isn't true" do
      controller.instance_variable_set(:@_frikandel_did_reset_session, true)
      controller.should_not_receive(:reset_session)
      controller.send(:reset_session_with_bind_session_to_ip_address_style)
    end

    it "resets session and restores ttl & max_ttl if frikandel did limit session lifetime" do
      controller.stub(:frikandel_did_limit_session_lifetime?).and_return(true)

      session[:ttl] = "SomeTTL"
      session[:max_ttl] = "SomeMaxTTL"

      controller.should_receive(:reset_session).and_call_original
      controller.send(:reset_session_with_bind_session_to_ip_address_style)

      session[:ttl].should eql("SomeTTL")
      session[:max_ttl].should eql("SomeMaxTTL")
    end
  end


  context ".frikandel_did_limit_session_lifetime?" do
    it "returns true if instance variable @_frikandel_did_validate_session_timestamp is true" do
      controller.send(:frikandel_did_limit_session_lifetime?).should be_false
      controller.instance_variable_set(:@_frikandel_did_validate_session_timestamp, true)
      controller.send(:frikandel_did_limit_session_lifetime?).should be_true
    end

    it "returns true if instance variable @_frikandel_did_persist_session_timestamp is true" do
      controller.send(:frikandel_did_limit_session_lifetime?).should be_false
      controller.instance_variable_set(:@_frikandel_did_persist_session_timestamp, true)
      controller.send(:frikandel_did_limit_session_lifetime?).should be_true
    end

    it "returns false if used instance variables aren't true" do
      controller.send(:frikandel_did_limit_session_lifetime?).should be_false
      controller.instance_variable_set(:@_frikandel_did_validate_session_timestamp, nil)
      controller.instance_variable_set(:@_frikandel_did_persist_session_timestamp, nil)
      controller.send(:frikandel_did_limit_session_lifetime?).should be_false
    end
  end
end
