class MainController < ApplicationController
  def index
    @report = Report.new(current_user)
  end

  def api_key
    # combine id, email, & password
    key = "#{current_user.id}:#{current_user.email}:#{current_user.encrypted_password}"

    @key = AuthToken.encrypt(Rails.application.secrets.secret_key_base, key)
  end
end
