require "spec_helper"
require "support/application_controller"

class CombinedController < ApplicationController
  include Frikandel::LimitSessionLifetime
  include Frikandel::BindSessionToIpAddress

  def home
    render text: "combined test"
  end
end

describe CombinedController do
  context "ttl nor ip isn't present in session" do
    it "resets the session" do
      session[:user_id] = 4337
      get :home

      session[:user_id].should be_blank
      session[:ttl].should be_present
      session[:ip_address].should be_present
    end

    it "allows the request to be rendered as normal" do
      get :home

      response.body.should eql("combined test")
    end
  end

  context "ttl or ip isn't present in session" do
    it "resets the session if ip address is missing" do
      session[:user_id] = 4337
      session[:ttl] = "Something"
      get :home

      session[:user_id].should be_blank

      session[:ttl].should be_present
      session[:ttl].should_not eql("Something")
      session[:ip_address].should be_present
    end

    it "resets the session if ttl is missing" do
      session[:user_id] = 4337
      session[:ip_address] = "Something"
      get :home

      session[:user_id].should be_blank

      session[:ttl].should be_present
      session[:ip_address].should be_present
      session[:ip_address].should eql("0.0.0.0")
    end
  end
end
