# frozen_string_literal: true

require 'test_helper'

class DashboardControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'unauthenticated should get redirected' do
    get dashboard_url
    check_not_authenticated
  end

  test 'authenticated staff should get dashboard' do
    sign_in users(:staffuser)
    get dashboard_url
    assert_response :success
  end

  test 'authenticated contact should get dashboard' do
    sign_in users(:c_one)
    get dashboard_url
    assert_response :success
  end
end
