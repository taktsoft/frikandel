module Frikandel
  module SessionInvalidation

    private

    def on_invalid_session
      reset_session
      redirect_to root_path
    end
    alias original_on_invalid_session on_invalid_session
  end
end
