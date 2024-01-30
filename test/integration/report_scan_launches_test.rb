# frozen_string_literal: true

require 'test_helper'

class ReportScanLaunchesTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'unauthenticated cannot see report launched scans' do
    get report_scan_launches_path(scan_reports(:mapui))
    check_not_authenticated
  end

  test 'authenticated staff only can see report launched scans' do
    sign_in users(:staffuser)
    report = scan_reports(:mapui)
    get report_scan_launches_path(report)
    assert_response 200
  end

  test 'unauthenticated cannot launch new scan' do
    get new_report_scan_launch_path(scan_reports(:mapui))
    check_not_authenticated
  end

  test 'unauthenticated cannot launch new zaproxy scan' do
    post zaproxy_report_scan_launches_path(scan_reports(:mapui))
    check_not_authenticated
  end

  test 'authenticated staff only can launch new scan for report' do
    sign_in users(:staffuser)
    report = scan_reports(:mapui)
    get new_report_scan_launch_path(report)
    assert_response 200
  end

  test 'launching a scan without scan_name but with auto_import causes no error' do
    launch_scan('zap-baseline-scan', '', 'http://something', ['-a', '-j'], { auto_import: true })
  end

  test 'authenticated staff only can launch new zap-baseline-scan scan' do
    launch_scan('zap-baseline-scan', 'Zap: something', 'http://something', ['-a', '-j'])
  end

  test 'authenticated staff only can launch new zap-full-scan scan' do
    launch_scan('zap-full-scan', 'Zap: Something', 'http://something', ['-a', '-j'])
  end

  test 'authenticated staff only can launch new zap-api-scan scan' do
    launch_scan('zap-api-scan', 'Zap: something', 'http://something', ['-f openapi'])
  end

  test 'unauthenticated cannot launch scan import from launched scan' do
    post import_scan_launch_path(scan_launches(:scan_launch_one))
    check_not_authenticated
  end

  test 'unauthenticated cannot delete launched scan' do
    delete scan_launch_path(scan_launches(:scan_launch_one))
    check_not_authenticated
  end

  test 'authenticated can delete launched scan' do
    sign_in users(:staffuser)
    scan_launch = scan_launches(:scan_launch_one)
    report = scan_launch.report
    delete scan_launch_path(scan_launch)
    assert_redirected_to report_scan_launches_path(report)
  end

  private

  def launch_scan(scan_type, scan_name, target, parameters, opts = {})
    opts[:auto_import] ||= false
    opts[:auto_aggregate] ||= false
    opts[:auto_aggregate_mixing] ||= false
    sign_in users(:staffuser)
    report = scan_reports(:mapui)
    scan_launches_count = report.scan_launches.count
    post zaproxy_report_scan_launches_path(report), params: {
      scan_launch: {
        scan_configuration_attributes: {
          scan_name: scan_name,
          scan_type: scan_type,
          target: target,
          parameters: parameters,
          auto_import: opts[:auto_import],
          auto_aggregate: opts[:auto_aggregate],
          auto_aggregate_mixing: opts[:auto_aggregate_mixing]
        }
      }
    }
    assert_redirected_to report_scan_launches_path(report)
    report.reload
    assert_equal report.scan_launches.count, scan_launches_count + 1
    # Find_by(scan_name is removed from fields list as it can be dynamically set when empty string
    # provided)
    find_by_hash = {
      scan_type: scan_type, target: target,
      parameters: parameters.join(' '), auto_import: opts[:auto_import],
      auto_aggregate: opts[:auto_aggregate], auto_aggregate_mixing: opts[:auto_aggregate_mixing]
    }
    # For further scanners implementations, we will need to replace zaproxy by corresponding
    # scanner
    find_by_hash[scan_name: "zaproxy: #{target}"] if scan_name.blank?
    scan_configuration = ScanConfiguration.find_by(find_by_hash)
    assert scan_configuration.present?
    scan_launch = ScanLaunch.find_by(
      scan_configuration: scan_configuration,
      report: report
    )
    assert scan_launch.present?
  end
end
