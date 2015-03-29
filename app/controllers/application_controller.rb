class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :authenticate_user_from_token!
  before_action :authenticate_user!

  protected
  def authenticate_user_from_token!
    return unless auth = request.headers['Authentication']

    # decode token
    auth = auth.split
    user_id, token = Base64.decode64(auth[1]).split

    user = User.find(user_id)

    if ::BCrypt::Password.new(user.encrypted_api_token) == token
      sign_in user, store: false
    end
  end
end
