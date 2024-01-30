# frozen_string_literal: true

require 'test_helper'
require 'json'

class WhoisControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'unauthenticated cannot use whois function' do
    post whois_path
    check_unauthorized
  end

  test 'authenticated can use whois function' do
    sign_in users(:staffuser)
    post whois_path, params: {
      target: '8.8.8.8'
    }
    assert_response :success
    assert_match(/ARIN WHOIS data and services are subject to the Terms of Use/,
      JSON.parse(@response.body)['html'])
  end

  test 'authenticated cannot use whois function with anything' do
    sign_in users(:staffuser)
    post whois_path, params: {
      target: 'anything'
    }
    assert_response :success
    assert_equal "Unable to find a WHOIS server for `anything'",
      JSON.parse(@response.body)['html']
  end
end
