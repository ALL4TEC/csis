# frozen_string_literal: true

require 'test_helper'

class ReportScanLaunchesTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'report\'s scans imports list renders without error' do
    sign_in users(:staffuser)
    report_scan_import = report_scan_imports(:report_scan_import_one)
    get "/reports/#{report_scan_import.report.id}/scan_imports"
    assert_response 200
  end
end
