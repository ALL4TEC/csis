# frozen_string_literal: true

require 'test_helper'

class OmniauthTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include Devise::Controllers::Helpers

  test 'user can log in via google_oauth2 if email present in database' do
    run_test('staff.user@somedomain.com', 'Staff User', true)
  end

  test 'user cannot log in via google_oauth2 if email not present in database' do
    run_test('unknown.person@mystery.com', 'Unknown Person', false)
  end

  test 'user cannot log in via google_oauth2 if account not activated' do
    run_test('inactif@somedomain.eu', 'inactif', false)
  end

  test 'user can log in via azure_oauth2 if email present in database' do
    run_test('staff.user@somedomain.com', 'Staff User', true, 'azure_oauth2')
  end

  test 'user cannot log in via azure_oauth2 if email not present in database' do
    run_test('unknown.person@mystery.com', 'Unknown Person', false, 'azure_oauth2')
  end

  test 'user cannot log in via azure_oauth2 if account not activated' do
    run_test('inactif@somedomain.eu', 'inactif', false, 'azure_oauth2')
  end

  test 'user cannot log in via omniauth if provider sends different name' do
    run_test('staff.user@somedomain.com', 'Staff User', false, 'azure_oauth2', 'Lecureuil')
  end

  test 'Google OAuth route redirects to Google OAuth prompt' do
    post '/users/auth/google_oauth2'
    assert_response :redirect
  end

  test 'Microsoft OAuth route redirects to Microsoft OAuth prompt' do
    post '/users/auth/azure_oauth2'
    assert_response :redirect
  end

  private

  def mock_omni_auth(email, name, provider, provider_name)
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[provider] = OmniAuth::AuthHash.new(
      provider: provider,
      uid: '123545',
      info: {
        email: email,
        name: provider_name.presence || name,
        image: 'avatar.url'
      },
      extra: {
        raw_info: {
          email: email
        }
      }
    )
  end

  def assert_auth(auth_ok)
    auth_ok ? (assert user_signed_in?) : check_not_authenticated
  end

  def run_test(email, name, auth_ok, provider = 'google_oauth2', provider_name = nil)
    mock_omni_auth(email, name, provider, provider_name)

    get send(:"user_#{provider}_omniauth_authorize_path")
    # request.env['devise.mapping'] = Devise.mappings[:user]
    request.env['omniauth.auth'] = OmniAuth.config.mock_auth[provider]

    controller = Users::OmniauthCallbacksController.new
    controller.request = request
    controller.response = response
    controller.send(provider.to_sym)

    assert_auth(auth_ok)
  end
end
