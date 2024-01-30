# frozen_string_literal: true

require 'test_helper'

class JobsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'unauthenticated cannot see jobs' do
    get jobs_path
    check_not_authenticated
  end

  test 'authenticated staff super_admin only can see all jobs' do
    sign_in users(:staffuser)
    get jobs_path
    check_not_authorized
    sign_in users(:superadmin)
    get jobs_path
    assert_response 200
  end
end
