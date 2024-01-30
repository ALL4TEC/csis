# frozen_string_literal: true

require 'test_helper'

class PrivateIpValidatorTest < ActiveSupport::TestCase
  test 'local IP adresses are valid' do
    assert(PrivateIpValidator.local_cluster_request_origin?('127.0.0.1'))
    assert(PrivateIpValidator.local_cluster_request_origin?('10.0.0.0'))
    assert(PrivateIpValidator.local_cluster_request_origin?('192.168.0.0'))
  end

  test 'not whitelisted remote IP adresses are not valid' do
    assert_not(PrivateIpValidator.local_cluster_request_origin?('1.1.1.1'))
    assert_not(PrivateIpValidator.local_cluster_request_origin?('80.125.163.172'))
  end

  test 'whitelisted remote IP adresses are valid' do
    assert(PrivateIpValidator.local_cluster_request_origin?('8.8.8.8'))
    assert(PrivateIpValidator.local_cluster_request_origin?('193.252.117.145'))
  end
end
