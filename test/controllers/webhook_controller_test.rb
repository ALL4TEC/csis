# frozen_string_literal: true

require 'test_helper'

class WebhookControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'webhook works' do
    post webhook_sellsy_3455ecd1_1d58_4e57_842f_c3d691694d24_path
    assert_response 204
  end
  
  test 'webhook correctly return :ok if error raised' do
    # GIVEN
    # A webhook available at known url
    # Bad data passed as body
    user = users(:staffuser)
    sign_in user
    # WHEN
    # scan launch data comes from Scb gateway
    post "/webhook/securecodebox/#{ENV.fetch('SECURE_CODE_BOX_WH_UUID', nil)}", params: {
      key: 'value'
    }
    # THEN
    # Gateway response is opaque
    assert_response :ok
  end
end
