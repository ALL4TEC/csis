# frozen_string_literal: true

require 'test_helper'

class ChangelogTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'unauthenticated cannot see changelog' do
    get '/changelog'
    check_unauthorized
  end
end
