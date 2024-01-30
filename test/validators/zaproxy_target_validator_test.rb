# frozen_string_literal: true

require 'test_helper'

class ZaproxyTargetValidatorTest < ActiveSupport::TestCase
  test 'Url starting with http is valid' do
    scan_configuration = ScanConfiguration.new(
      launcher: User.first, scanner: :zaproxy, scan_type: 'zap-baseline-scan',
      target: 'http://something.com'
    )
    assert(scan_configuration.valid?)
    scan_configuration = ScanConfiguration.new(
      launcher: User.first, scanner: :zaproxy, scan_type: 'zap-baseline-scan',
      target: " \thttp://xxxcccsd\t"
    )
    assert(scan_configuration.valid?)
  end

  test 'Url starting with https is valid' do
    scan_configuration = ScanConfiguration.new(
      launcher: User.first, scanner: :zaproxy, scan_type: 'zap-baseline-scan',
      target: 'https://something.com'
    )
    assert(scan_configuration.valid?)
    scan_configuration = ScanConfiguration.new(
      launcher: User.first, scanner: :zaproxy, scan_type: 'zap-baseline-scan',
      target: " \thttps://xxxcccsd\t"
    )
    assert(scan_configuration.valid?)
  end

  test 'Ip is not valid' do
    scan_configuration = ScanConfiguration.new(
      launcher: User.first, scanner: :zaproxy, scan_type: 'zap-baseline-scan', target: '1.2.3.4'
    )
    assert_not(scan_configuration.valid?)
  end

  test 'Url starting with something else than http or https is not valid' do
    scan_configuration = ScanConfiguration.new(
      launcher: User.first, scanner: :zaproxy, scan_type: 'zap-baseline-scan',
      target: 'www.test.com'
    )
    assert_not(scan_configuration.valid?)
  end
end
