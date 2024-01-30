# frozen_string_literal: true

require 'test_helper'

class ScheduledScansTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'unauthenticated cannot see project scheduled scans' do
    get project_scheduled_scans_path(projects(:project_one))
    check_not_authenticated
  end

  test 'authenticated staff only can see project scheduled scans' do
    sign_in users(:staffuser)
    project = projects(:project_one)
    get project_scheduled_scans_path(project)
    assert_response 200
  end

  test 'unauthenticated cannot schedule new scan' do
    get new_project_scheduled_scan_path(projects(:project_one))
    check_not_authenticated
  end

  test 'unauthenticated cannot schedule new zaproxy scan' do
    post zaproxy_project_scheduled_scans_path(projects(:project_one))
    check_not_authenticated
  end

  test 'authenticated staff only can schedule new scan for project' do
    sign_in users(:staffuser)
    project = projects(:project_one)
    get new_project_scheduled_scan_path(project)
    assert_response 200
  end

  test 'scheduling a scan without scan_name but with auto_import causes no error' do
    schedule_scan('zap-baseline-scan', '', 'http://something', ['-a', '-j'], { auto_import: true })
  end

  test 'authenticated staff only can schedule new zap-baseline-scan scan' do
    schedule_scan('zap-baseline-scan', 'Zap: something', 'http://something', ['-a', '-j'])
  end

  test 'authenticated staff only can schedule new zap-full-scan scan' do
    schedule_scan('zap-full-scan', 'Zap: Something', 'http://something', ['-a', '-j'])
  end

  test 'authenticated staff only can schedule new zap-api-scan scan' do
    schedule_scan('zap-api-scan', 'Zap: something', 'http://something', ['-f openapi'])
  end

  test 'unauthenticated cannot activate a scheduled scan' do
    put activate_scheduled_scan_path(scheduled_scans(:scheduled_scan_one))
    check_not_authenticated
  end

  test 'unauthenticated cannot deactivate a scheduled scan' do
    put deactivate_scheduled_scan_path(scheduled_scans(:scheduled_scan_two))
    check_not_authenticated
  end

  test 'unauthenticated cannot delete scheduled scan' do
    delete scheduled_scan_path(scheduled_scans(:scheduled_scan_one))
    check_not_authenticated
  end

  test 'authenticated can activate scheduled scan only if deactivated' do
    # GIVEN a !discarded scheduled_scan
    sign_in users(:staffuser)
    scheduled_scan = scheduled_scans(:scheduled_scan_one)
    assert_not scheduled_scan.discarded?
    # WHEN
    # calling /activate
    put activate_scheduled_scan_path(scheduled_scan)
    # THEN
    # not authorized
    check_not_authorized
    # GIVEN a discarded scheduled_scan
    scheduled_scan.discard!
    assert_not Resque.schedule.key?(scheduled_scan.scheduled_scan_name)
    assert scheduled_scan.discarded?
    # WHEN
    # calling /activate
    put activate_scheduled_scan_path(scheduled_scan)
    # THEN
    # scheduled_scan is activated
    # readded to Resque.schedule
    scheduled_scan.reload
    assert_not scheduled_scan.discarded?
    assert Resque.schedule.key?(scheduled_scan.scheduled_scan_name)
  end

  test 'authenticated can deactivate scheduled_scan only if activated' do
    # GIVEN a discarded scheduled_scan
    sign_in users(:staffuser)
    scheduled_scan = scheduled_scans(:scheduled_scan_one)
    scheduled_scan.discard!
    assert scheduled_scan.discarded?
    # WHEN
    # calling /deactivate
    put deactivate_scheduled_scan_path(scheduled_scan)
    # THEN
    # not authorized
    check_not_authorized
    # GIVEN a !discarded scheduled_scan
    scheduled_scan.undiscard!
    assert_not scheduled_scan.discarded?
    # WHEN
    # calling /deactivate
    put deactivate_scheduled_scan_path(scheduled_scan)
    # THEN
    # scheduled_scan is deactivated
    # removed from Resque.schedule
    scheduled_scan.reload
    assert scheduled_scan.discarded?
    assert_not Resque.schedule.key?(scheduled_scan.scheduled_scan_name)
  end

  test 'authenticated can delete scheduled scan only if no scan_launch is linked to it' do
    sign_in users(:staffuser)
    scheduled_scan = scheduled_scans(:scheduled_scan_one)
    project = scheduled_scan.project
    scheduled_scans_count = project.scheduled_scans.count
    delete scheduled_scan_path(scheduled_scan)
    check_not_authorized
    scheduled_scan.scan_configuration.scan_launches.destroy_all
    assert scheduled_scan.scan_launches.count.zero?
    delete scheduled_scan_path(scheduled_scan)
    assert_redirected_to project_scheduled_scans_path(project)
    assert_equal scheduled_scans_count - 1, project.scheduled_scans.count
  end

  private

  def schedule_scan(scan_type, scan_name, target, parameters, opts = {})
    opts[:auto_import] ||= false
    opts[:auto_aggregate] ||= false
    opts[:auto_aggregate_mixing] ||= false
    opts[:scan_launch_cron] ||= '0 2 * * *'
    opts[:report_action] ||= :last
    sign_in users(:staffuser)
    project = projects(:project_one)
    scheduled_scans_count = project.scheduled_scans.count
    post zaproxy_project_scheduled_scans_path(project), params: {
      scheduled_scan: {
        scan_configuration_attributes: {
          scan_name: scan_name,
          scan_type: scan_type,
          target: target,
          parameters: parameters,
          auto_import: opts[:auto_import],
          auto_aggregate: opts[:auto_aggregate],
          auto_aggregate_mixing: opts[:auto_aggregate_mixing]
        },
        scan_launch_cron: opts[:scan_launch_cron],
        report_action: opts[:report_action]
      }
    }
    assert_redirected_to project_scheduled_scans_path(project)
    project.reload
    assert_equal project.scheduled_scans.count, scheduled_scans_count + 1
    # Find_by(scan_name is removed from fields list as it can be dynamically set when empty string
    # provided)
    find_by_hash = {
      scan_type: scan_type, target: target,
      parameters: parameters.join(' '), auto_import: opts[:auto_import],
      auto_aggregate: opts[:auto_aggregate], auto_aggregate_mixing: opts[:auto_aggregate_mixing]
    }
    find_by_hash[scan_name: "zaproxy: #{target}"] if scan_name.blank?
    scan_configuration = ScanConfiguration.find_by(find_by_hash)
    assert scan_configuration.present?
    scheduled_scan = ScheduledScan.find_by(
      scan_configuration: scan_configuration,
      project: project
    )
    assert scheduled_scan.present?
  end
end
