require "spec_helper"
require "support/application_controller"

class BindSessionToIpAddressController < ApplicationController
  include Frikandel::BindSessionToIpAddress

  def home
    render text: "bind test"
  end
end

describe BindSessionToIpAddressController do
  it "writes current ip address to session" do
    expect(session[:ip_address]).to be_nil
    get :home
    expect(session[:ip_address]).to eql("0.0.0.0")
  end

  it "raises an exception if session address and current ip address don't match" do
    session[:ip_address] = "1.2.3.4"
    controller.should_receive(:on_invalid_session)

    get :home
  end


  context "ip address isn't present in session" do
    it "resets the session" do
      session[:user_id] = 4337
      get :home

      session[:user_id].should be_blank
    end

    it "allows the request to be rendered as normal" do
      get :home

      response.body.should eql("bind test")
    end
  end
end
