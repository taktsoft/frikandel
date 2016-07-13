require "rails_helper"
require "support/application_controller"


class SessionInvalidError < StandardError; end

class CustomizedOnInvalidSessionController < ApplicationController
  include Frikandel::LimitSessionLifetime

  def on_invalid_session
    raise SessionInvalidError.new("Your Session is DEAD!")
  end
  alias my_on_invalid_session on_invalid_session
end


RSpec.describe CustomizedOnInvalidSessionController do
  it "uses the overwritten on_invalid_cookie function" do
    get :home
    request.session[:max_ttl] = 1.minute.ago

    expect { get :home }.to raise_error SessionInvalidError
  end

  it "can revert the on_invalid_cookie function back to the original" do
    # NOTE: Don't confuse original_on_invalid_session with my_on_invalid_session!
    class CustomizedOnInvalidSessionController < ApplicationController
      alias on_invalid_session original_on_invalid_session # Setting it to the Gems original
    end

    get :home
    request.session[:max_ttl] = 1.minute.ago

    begin
      expect { get :home }.to_not raise_error
    ensure
      class CustomizedOnInvalidSessionController < ApplicationController
        alias on_invalid_session my_on_invalid_session # Reverting it back to the Customized function thats defined in this test
      end
    end
  end
end
