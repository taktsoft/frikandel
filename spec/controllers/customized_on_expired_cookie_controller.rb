require "spec_helper"
require "support/application_controller"

class CookieExpiredError < StandardError; end

class CustomizedOnExpiredCookieController < ApplicationController
  def on_expired_cookie
    raise CookieExpiredError.new("Your Cookie is DEAD!")
  end
  alias my_on_expired_cookie on_expired_cookie
end

describe CustomizedOnExpiredCookieController do

  it "uses the overwritten on_expired_cookie function" do
    get :home
    request.session[:max_ttl] = 1.minute.ago

    expect { get :home }.to raise_error CookieExpiredError
  end

  it "can revert the on_expired_cookie function back to the original" do
    # NOTE: Don't confuse original_on_expired_cookie with my_on_expired_cookie!
    class CustomizedOnExpiredCookieController < ApplicationController
      alias on_expired_cookie original_on_expired_cookie # Setting it to the Gems original
    end

    get :home
    request.session[:max_ttl] = 1.minute.ago

    begin
      expect { get :home }.to_not raise_error
    ensure
      class CustomizedOnExpiredCookieController < ApplicationController
        alias on_expired_cookie my_on_expired_cookie # Reverting it back to the Customized function thats defined in this test
      end
    end
  end
end
