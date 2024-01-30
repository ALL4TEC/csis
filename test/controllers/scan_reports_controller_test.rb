# frozen_string_literal: true

require 'test_helper'

class ScanReportsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'unauthenticated cannot notify contacts' do
    report = scan_reports(:scan_report_auto)
    post notify_report_path(report)
    check_not_authenticated
  end

  test 'authenticated staff can notify contacts' do
    sign_in users(:staffuser)
    report = scan_reports(:scan_report_auto)
    post notify_report_path(report)
    assert_redirected_to scan_report_path(report)
    assert_equal I18n.t('reports.notices.mailed'), flash[:notice]
  end

  test 'unauthenticated cannot auto generate aggregates with mixing' do
    report = scan_reports(:mapui2)
    post auto_aggregate_report_path(report), params: { mixing: true }
    check_not_authenticated
  end

  test 'authenticated staff can auto generate aggregates with mixing' do
    sign_in users(:staffuser)
    report = scan_reports(:mapui2)
    count = report.aggregates.count
    post auto_aggregate_report_path(report), params: { mixing: true }
    assert_redirected_to report_aggregates_path(report)
    assert_equal I18n.t('reports.notices.auto_aggregated'), flash[:notice]
    assert report.aggregates.count > count
  end

  test 'unauthenticated cannot auto generate aggregates without mixing' do
    report = scan_reports(:mapui2)
    post auto_aggregate_report_path(report), params: { mixing: false }
    check_not_authenticated
  end

  test 'authenticated staff can auto generate aggregates without mixing' do
    sign_in users(:staffuser)
    report = scan_reports(:mapui2)
    count = report.aggregates.count
    post auto_aggregate_report_path(report), params: { mixing: false }
    assert_redirected_to report_aggregates_path(report)
    assert_equal I18n.t('reports.notices.auto_aggregated'), flash[:notice]
    assert report.aggregates.count > count
  end
end
