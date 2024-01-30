# frozen_string_literal: true

require 'test_helper'

class DeviseTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'unauthenticated can access reset password form' do
    get new_user_password_path
    assert_response :success
  end

  test 'unauthenticated cannot know if email is present when sending reset password form' do
    post user_password_path, params: {
      email: 'something@notpresent.fr'
    }
    check_not_authenticated
    assert(flash[:notice].present?)
  end
end
