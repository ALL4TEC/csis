# frozen_string_literal: true

require 'test_helper'

class UrlHelpersTest < ActionDispatch::IntegrationTest
  include Devise::Controllers::UrlHelpers
  include Rails.application.routes.url_helpers

  test 'reset_password_instructions path does not contain point' do
    host = 'www.example.com'
    default_url_options[:host] = host
    token = 'tokn'
    expected = "http://#{host}/users/password/edit?reset_password_token=#{token}"
    # can check existing routes:
    assert_equal expected, edit_password_url(User.first, reset_password_token: token)
  end
end
