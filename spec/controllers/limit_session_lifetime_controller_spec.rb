require "rails_helper"
require "support/application_controller"


class LimitSessionLifetimeController < ApplicationController
  include Frikandel::LimitSessionLifetime

  if respond_to?(:before_action)
    before_action :flash_alert_and_redirect_home, only: [:redirect_home]
  else
    before_filter :flash_alert_and_redirect_home, only: [:redirect_home]
  end

  def home
    if Rails::VERSION::MAJOR >= 5
      render plain: "ttl test"
    else
      render text: "ttl test"
    end
  end

  def redirect_home
  end

protected

  def flash_alert_and_redirect_home
    flash[:alert] = "alert test"

    redirect_to limit_session_lifetime_home_url
  end
end


RSpec.describe LimitSessionLifetimeController do
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

      expect(flash).not_to be_empty
      expect(flash[:alert]).to eql("alert test")
    end

    it "holds the session for at least .1 seconds" do
      get :home

      session[:user_id] = 1337
      sleep 0.1

      get :home

      expect(session[:user_id]).to be_present
      expect(session[:user_id]).to eq 1337
    end

    it "destroys the session after SESSION_TTL" do
      get :home

      session[:user_id] = 2337
      session[:ttl] = (Frikandel::Configuration.ttl + 1.minute).seconds.ago

      get :home

      expect(session[:user_id]).to be_blank
    end

    it "destroys the session after SESSION_MAX_TTL" do
      get :home

      session[:user_id] = 3337
      request.session[:max_ttl] = 1.minute.ago

      get :home

      expect(session[:user_id]).to be_blank
    end

    it "is configurable" do
      Frikandel::Configuration.ttl = 1.minute
      get :home

      session[:ttl] = 30.minutes.ago
      session[:user_id] = 5337

      get :home

      expect(session[:user_id]).to be_blank
    end


    context "ttl isn't present in session" do
      it "resets the session and persists ttl & max_ttl" do
        session[:user_id] = 4337
        session[:ip_address] = "SomeIP"
        session.delete(:ttl)
        session[:max_ttl] = "SomeMaxTTL"

        expect(controller).to receive(:reset_session).and_call_original
        expect(controller).to receive(:persist_session_timestamp).and_call_original
        get :home

        expect(session[:user_id]).to be_blank
        expect(session[:ip_address]).to be_blank
        expect(session[:ttl]).to be_present
        expect(session[:ttl]).to be_a(Time)
        expect(session[:max_ttl]).to be_present
        expect(session[:max_ttl]).not_to eql("SomeMaxTTL")
        expect(session[:max_ttl]).to be_a(Time)
      end

      it "allows the request to be rendered as normal" do
        session.delete(:ttl)
        session[:max_ttl] = "SomeMaxTTL"

        get :home

        expect(response.body).to eql("ttl test")
      end
    end


    context "max_ttl isn't present in session" do
      it "resets the session and persists ttl & max_ttl" do
        session[:user_id] = 4337
        session[:ip_address] = "SomeIP"
        session[:ttl] = "SomeTTL"
        session.delete(:max_ttl)

        expect(controller).to receive(:reset_session).and_call_original
        expect(controller).to receive(:persist_session_timestamp).and_call_original
        get :home

        expect(session[:user_id]).to be_blank
        expect(session[:ip_address]).to be_blank
        expect(session[:ttl]).to be_present
        expect(session[:ttl]).not_to eql("SomeTTL")
        expect(session[:ttl]).to be_a(Time)
        expect(session[:max_ttl]).to be_present
        expect(session[:max_ttl]).to be_a(Time)
      end

      it "allows the request to be rendered as normal" do
        session[:ttl] = "SomeTTL"
        session.delete(:max_ttl)

        get :home

        expect(response.body).to eql("ttl test")
      end
    end


    context "ttl and max_ttl isn't present in session" do
      it "resets the session and persists ttl & max_ttl" do
        session[:user_id] = 4337
        session[:ip_address] = "SomeIP"
        session.delete(:ttl)
        session.delete(:max_ttl)

        expect(controller).to receive(:reset_session).and_call_original
        expect(controller).to receive(:persist_session_timestamp).and_call_original
        get :home

        expect(session[:user_id]).to be_blank
        expect(session[:ip_address]).to be_blank
        expect(session[:ttl]).to be_present
        expect(session[:ttl]).to be_a(Time)
        expect(session[:max_ttl]).to be_present
        expect(session[:max_ttl]).to be_a(Time)
      end

      it "allows the request to be rendered as normal" do
        session.delete(:ttl)
        session.delete(:max_ttl)

        get :home

        expect(response.body).to eql("ttl test")
      end
    end
  end


  context ".validate_session_timestamp" do
    it "calls on_invalid_session if ttl is reached" do
      session[:ttl] = "SomeTTL"
      session[:max_ttl] = "SomeMaxTTL"

      expect(controller).to receive(:reached_ttl?).and_return(true)
      allow(controller).to receive(:reached_max_ttl?).and_return(false)

      expect(controller).to receive(:on_invalid_session)

      controller.send(:validate_session_timestamp)
    end

    it "calls on_invalid_session if max_ttl is reached" do
      session[:ttl] = "SomeTTL"
      session[:max_ttl] = "SomeMaxTTL"

      allow(controller).to receive(:reached_ttl?).and_return(false)
      expect(controller).to receive(:reached_max_ttl?).and_return(true)

      expect(controller).to receive(:on_invalid_session)

      controller.send(:validate_session_timestamp)
    end

    it "calls on_invalid_session if ttl and max_ttl are reached" do
      session[:ttl] = "SomeTTL"
      session[:max_ttl] = "SomeMaxTTL"

      allow(controller).to receive(:reached_ttl?).and_return(true)
      allow(controller).to receive(:reached_max_ttl?).and_return(true)

      expect(controller).to receive(:on_invalid_session)

      controller.send(:validate_session_timestamp)
    end

    it "calls reset_session if ttl isn't persisted in session" do
      session.delete(:ttl)
      session[:max_ttl] = "SomeMaxTTL"

      expect(controller).to receive(:reset_session)

      controller.send(:validate_session_timestamp)
    end

    it "calls reset_session if max_ttl isn't persisted in session" do
      session[:ttl] = "SomeTTL"
      session.delete(:max_ttl)

      expect(controller).to receive(:persist_session_timestamp)

      controller.send(:validate_session_timestamp)
    end

    it "calls reset_session if ttl and max_ttl aren't persisted in session" do
      session.delete(:ttl)
      session.delete(:max_ttl)

      expect(controller).to receive(:persist_session_timestamp)

      controller.send(:validate_session_timestamp)
    end

    it "calls persist_session_timestamp if validation passes" do
      session[:ttl] = "SomeTTL"
      session[:max_ttl] = "SomeMaxTTL"

      allow(controller).to receive(:reached_ttl?).and_return(false)
      allow(controller).to receive(:reached_max_ttl?).and_return(false)

      expect(controller).to receive(:persist_session_timestamp)

      controller.send(:validate_session_timestamp)
    end
  end


  context ".reached_ttl?" do
    it "returns true if persisted ttl is less than configured ttl seconds ago" do
      current_time = Time.now
      allow(Time).to receive(:now).and_return(current_time)

      session[:ttl] = current_time.ago(Frikandel::Configuration.ttl + 1)

      expect(controller.send(:reached_ttl?)).to be_truthy
    end

    it "returns false if persisted ttl is equal to configured ttl seconds ago" do
      current_time = Time.now
      allow(Time).to receive(:now).and_return(current_time)

      session[:ttl] = current_time.ago(Frikandel::Configuration.ttl)

      expect(controller.send(:reached_ttl?)).to be_falsey
    end

    it "returns false if persisted ttl is greater than configured ttl seconds ago" do
      current_time = Time.now
      allow(Time).to receive(:now).and_return(current_time)

      session[:ttl] = current_time.ago(Frikandel::Configuration.ttl - 1)

      expect(controller.send(:reached_ttl?)).to be_falsey
    end
  end


  context ".reached_max_ttl?" do
    it "returns true if persisted max_ttl is less than current time" do
      current_time = Time.now
      allow(Time).to receive(:now).and_return(current_time)

      session[:max_ttl] = current_time.ago(1)

      expect(controller.send(:reached_max_ttl?)).to be_truthy
    end

    it "returns false if persisted max_ttl is equal to current time" do
      current_time = Time.now
      allow(Time).to receive(:now).and_return(current_time)

      session[:max_ttl] = current_time

      expect(controller.send(:reached_max_ttl?)).to be_falsey
    end

    it "returns false if persisted max_ttl is greater than current time" do
      current_time = Time.now
      allow(Time).to receive(:now).and_return(current_time)

      session[:max_ttl] = current_time.since(1)

      expect(controller.send(:reached_max_ttl?)).to be_falsey
    end
  end


  context ".persist_session_timestamp" do
    it "sets ttl to current time" do
      current_time = Time.now
      allow(Time).to receive(:now).and_return(current_time)

      expect {
        controller.send(:persist_session_timestamp)
      }.to change {
        session[:ttl]
      }.from(nil).to(current_time)
    end

    it "sets max_ttl to configured max_ttl seconds in future if it's blank" do
      current_time = Time.now
      max_ttl_time = current_time.since(Frikandel::Configuration.max_ttl)
      allow(Time).to receive(:now).and_return(current_time)

      expect {
        controller.send(:persist_session_timestamp)
      }.to change {
        session[:max_ttl]
      }.from(nil).to(max_ttl_time)
    end

    it "doesn't set max_ttl if it's present" do
      session[:max_ttl] = "SomeMaxTTL"

      expect {
        controller.send(:persist_session_timestamp) # second call, shouldn't change max_ttl
        }.to_not change {
          session[:max_ttl]
        }.from("SomeMaxTTL")
    end
  end


  context ".reset_session" do
    it "calls persist_session_timestamp" do
      expect(controller).to receive(:persist_session_timestamp).and_call_original
      controller.send(:reset_session)
    end
  end
end
