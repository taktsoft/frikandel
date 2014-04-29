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
  context "requests" do
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

      flash.should_not be_empty
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
      it "resets the session (if frikandel didn't bind session to ip address)" do
        session[:user_id] = 4337
        session[:ip_address] = "SomeIP"
        session.delete(:ttl)
        session[:max_ttl] = "SomeMaxTTL"

        controller.stub(:frikandel_did_bind_session_to_ip_address?).and_return(false)
        get :home

        session[:user_id].should be_blank
        session[:ip_address].should be_blank
        session[:ttl].should be_present
        session[:max_ttl].should be_present
        session[:max_ttl].should_not eql("SomeMaxTTL")
      end

      it "resets the session, but keeps ip_address if frikandel did bind session to ip address" do
        session[:user_id] = 4337
        session[:ip_address] = "SomeIP"
        session.delete(:ttl)
        session[:max_ttl] = "SomeMaxTTL"

        controller.stub(:frikandel_did_bind_session_to_ip_address?).and_return(true)
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
      it "resets the session (if frikandel didn't bind session to ip address)" do
        session[:user_id] = 4337
        session[:ip_address] = "SomeIP"
        session[:ttl] = "SomeTTL"
        session.delete(:max_ttl)

        controller.stub(:frikandel_did_bind_session_to_ip_address?).and_return(false)
        get :home

        session[:user_id].should be_blank
        session[:ip_address].should be_blank
        session[:ttl].should be_present
        session[:ttl].should_not eql("SomeTTL")
        session[:max_ttl].should be_present
      end

      it "resets the session, but keeps ip_address if frikandel did bind session to ip address" do
        session[:user_id] = 4337
        session[:ip_address] = "SomeIP"
        session[:ttl] = "SomeTTL"
        session.delete(:max_ttl)

        controller.stub(:frikandel_did_bind_session_to_ip_address?).and_return(true)
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
      it "resets the session (if frikandel didn't bind session to ip address)" do
        session[:user_id] = 4337
        session[:ip_address] = "SomeIP"

        controller.stub(:frikandel_did_bind_session_to_ip_address?).and_return(false)
        get :home

        session[:user_id].should be_blank
        session[:ip_address].should be_blank
        session[:ttl].should be_present
        session[:max_ttl].should be_present
      end

      it "resets the session, but keeps ip_address if frikandel did bind session to ip address" do
        session[:user_id] = 4337
        session[:ip_address] = "SomeIP"

        controller.stub(:frikandel_did_bind_session_to_ip_address?).and_return(true)
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


  context ".validate_session_timestamp" do
    it "sets instance variable @_frikandel_did_validate_session_timestamp to true on pass" do
      controller.send(:persist_session_timestamp) # to let the validation pass

      expect {
        controller.should_not_receive(:on_invalid_session)
        controller.should_not_receive(:reset_session_with_limit_session_lifetime_style)
        controller.should_not_receive(:persist_session_timestamp)

        controller.send(:validate_session_timestamp)
      }.to change {
        controller.instance_variable_get(:@_frikandel_did_validate_session_timestamp)
      }.from(nil).to(true)
    end
  end


  context ".persist_session_timestamp" do
    it "sets instance variable @_frikandel_did_persist_session_timestamp to true" do
      expect {
        controller.send(:persist_session_timestamp)
      }.to change {
        controller.instance_variable_get(:@_frikandel_did_persist_session_timestamp)
      }.from(nil).to(true)
    end
  end


  context ".reset_session_with_limit_session_lifetime_style" do
    it "sets instance variable @_frikandel_did_reset_session to true" do
      session[:ip_address] = "SomeIP"

      expect {
        controller.send(:reset_session_with_limit_session_lifetime_style)
      }.to change {
        controller.instance_variable_get(:@_frikandel_did_reset_session)
      }.from(nil).to(true)

      session[:ip_address].should be_nil
    end

    it "resets session only if instance variable @_frikandel_did_reset_session isn't true" do
      session[:ip_address] = "SomeIP"

      controller.instance_variable_set(:@_frikandel_did_reset_session, true)
      controller.should_not_receive(:reset_session)
      controller.send(:reset_session_with_limit_session_lifetime_style)

      session[:ip_address].should eql("SomeIP")
    end

    it "resets session and restores ip_address if frikandel did bind session to ip address" do
      controller.stub(:frikandel_did_bind_session_to_ip_address?).and_return(true)

      session[:ip_address] = "SomeIP"

      controller.should_receive(:reset_session).and_call_original
      controller.send(:reset_session_with_limit_session_lifetime_style)

      session[:ip_address].should eql("SomeIP")
    end
  end


  context ".frikandel_did_bind_session_to_ip_address?" do
    it "returns true if instance variable @_frikandel_did_validate_session_ip_address is true" do
      controller.send(:frikandel_did_bind_session_to_ip_address?).should be_false
      controller.instance_variable_set(:@_frikandel_did_validate_session_ip_address, true)
      controller.send(:frikandel_did_bind_session_to_ip_address?).should be_true
    end

    it "returns true if instance variable @_frikandel_did_persist_session_ip_address is true" do
      controller.send(:frikandel_did_bind_session_to_ip_address?).should be_false
      controller.instance_variable_set(:@_frikandel_did_persist_session_ip_address, true)
      controller.send(:frikandel_did_bind_session_to_ip_address?).should be_true
    end

    it "returns false if used instance variables aren't true" do
      controller.send(:frikandel_did_bind_session_to_ip_address?).should be_false
      controller.instance_variable_set(:@_frikandel_did_validate_session_ip_address, nil)
      controller.instance_variable_set(:@_frikandel_did_persist_session_ip_address, nil)
      controller.send(:frikandel_did_bind_session_to_ip_address?).should be_false
    end
  end
end
