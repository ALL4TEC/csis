# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    handle_oauth('Google')
  end

  def azure_oauth2
    handle_oauth('Microsoft')
  end

  private

  def handle_oauth(kind)
    auth = request.env['omniauth.auth']
    logger.debug auth

    email = auth[:info][:email]
    if email.nil? || User.find_by(email: email, state: :actif).nil?
      flash[:alert] = t 'users.errors.unauthorized_email'
      return redirect_to new_user_session_url
    end

    @user = User.from_omniauth(auth)
    if @user.blank?
      flash[:alert] = t 'users.errors.unauthorized_name'
      return redirect_to new_user_session_url
    end

    flash[:notice] = t 'devise.omniauth_callbacks.success', kind: kind
    PaperTrail::Version.create(
      item_type: 'User',
      item_id: @user.id,
      event: 'connection',
      whodunnit: @user.id
    )
    sign_in_and_redirect @user, event: :authentication
  end
end
