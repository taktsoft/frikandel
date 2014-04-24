require "spec_helper"
require "support/application_controller"

class SessionExpiredError < StandardError; end

class CustomizedOnExpiredSessionController < ApplicationController
  include Frikandel::LimitSessionLifetime

  def on_expired_session
    raise SessionExpiredError.new("Your Session is DEAD!")
  end
  alias my_on_expired_session on_expired_session
end

describe CustomizedOnExpiredSessionController do

  it "uses the overwritten on_expired_cookie function" do
    get :home
    request.session[:max_ttl] = 1.minute.ago

    expect { get :home }.to raise_error SessionExpiredError
  end

  it "can revert the on_expired_cookie function back to the original" do
    # NOTE: Don't confuse original_on_expired_session with my_on_expired_session!
    class CustomizedOnExpiredSessionController < ApplicationController
      alias on_expired_session original_on_expired_session # Setting it to the Gems original
    end

    get :home
    request.session[:max_ttl] = 1.minute.ago

    begin
      expect { get :home }.to_not raise_error
    ensure
      class CustomizedOnExpiredSessionController < ApplicationController
        alias on_expired_session my_on_expired_session # Reverting it back to the Customized function thats defined in this test
      end
    end
  end
end
