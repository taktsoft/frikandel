require "spec_helper"
require "support/application_controller"

class CookieExpiredError < StandardError; end

class CustomizedOnExpiredCookieController < ApplicationController
  def on_expired_cookie
    raise CookieExpiredError.new("Your Cookie is DEAD!")
  end
end

describe CustomizedOnExpiredCookieController do

  it "uses the overwritten on_expired_cookie function" do
    get :home
    request.session[:max_ttl] = 1.minute.ago

    expect { get :home }.to raise_error CookieExpiredError
  end
end
