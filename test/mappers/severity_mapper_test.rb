# frozen_string_literal: true

require 'test_helper'

class SeverityMapperTest < ActiveSupport::TestCase
  test 'returns default values when no customization is specified' do
    assert_equal('trivial', SeverityMapper.cvss_to_severity(0))
    assert_equal('low', SeverityMapper.cvss_to_severity(0.1))
    assert_equal('low', SeverityMapper.cvss_to_severity(3.9))
    assert_equal('medium', SeverityMapper.cvss_to_severity(4))
    assert_equal('medium', SeverityMapper.cvss_to_severity(6.9))
    assert_equal('high', SeverityMapper.cvss_to_severity(7))
    assert_equal('high', SeverityMapper.cvss_to_severity(8.9))
    assert_equal('critical', SeverityMapper.cvss_to_severity(9))
    assert_equal('critical', SeverityMapper.cvss_to_severity(10))
  end

  test 'adapts to customizations' do
    Customization.new(key: 'cvss_to_severity_low', value: '2').save
    Customization.new(key: 'cvss_to_severity_medium', value: '3').save
    Customization.new(key: 'cvss_to_severity_high', value: '5').save
    Customization.new(key: 'cvss_to_severity_critical', value: '9.5').save

    assert_equal('trivial', SeverityMapper.cvss_to_severity(0))
    assert_equal('trivial', SeverityMapper.cvss_to_severity(1.9))
    assert_equal('low', SeverityMapper.cvss_to_severity(2))
    assert_equal('low', SeverityMapper.cvss_to_severity(2.9))
    assert_equal('medium', SeverityMapper.cvss_to_severity(3))
    assert_equal('medium', SeverityMapper.cvss_to_severity(4.9))
    assert_equal('high', SeverityMapper.cvss_to_severity(5))
    assert_equal('high', SeverityMapper.cvss_to_severity(9.4))
    assert_equal('critical', SeverityMapper.cvss_to_severity(9.5))
    assert_equal('critical', SeverityMapper.cvss_to_severity(10))

    Customization.where("key LIKE 'cvss_to_severity%'").find_each(&:destroy)
  end
end
