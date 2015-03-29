class ApiTokensController < ApplicationController
  def show
    @has_token = current_user.encrypted_api_token.present?
  end

  def create
    token = SecureRandom.urlsafe_base64(nil, false)
    hashed_token = ::BCrypt::Password.create(token)
    current_user.update encrypted_api_token: hashed_token

    @bearer = Base64.encode64("#{current_user.id}:#{token}")
    @has_token = true
    render :show
  end
end
