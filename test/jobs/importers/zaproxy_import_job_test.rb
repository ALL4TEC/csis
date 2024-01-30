# frozen_string_literal: true

require 'test_helper'

module Importers
  class ZaproxyImportJobTest < ActiveJob::TestCase
    test 'Zaproxy scan is correctly imported' do
      scan_import = ScanImport.create!(
        importer: users(:staffuser), status: :scheduled, import_type: :zaproxy
      )
      attachment = {
        io: File.open('test/fixtures/files/JobTestValues/zaproxy_alerts.json'),
        filename: 'zaproxy.json',
        content_type: 'application/json',
        identify: false
      }
      report_scan_import = ReportScanImport.create!(
        report: scan_reports(:mapui), scan_import: scan_import, scan_name: 'somename',
        document: attachment
      )
      Importers::ZaproxyImportJob.perform_now(report_scan_import)
      assert_equal 'completed', scan_import.status
    end

    test 'Zaproxy scan import in error is correctly handled' do
      scan_import = ScanImport.create!(
        importer: users(:staffuser), status: :scheduled, import_type: :zaproxy
      )
      attachment = {
        io: File.open('test/fixtures/files/JobTestValues/burp_issues.xml'),
        filename: 'burp_issues.xml',
        content_type: 'application/xml',
        identify: false
      }
      report_scan_import = ReportScanImport.create!(
        report: scan_reports(:mapui), scan_import: scan_import, scan_name: 'somename',
        document: attachment
      )
      Importers::ZaproxyImportJob.perform_now(report_scan_import)
      assert_equal 'failed', scan_import.status
    end
  end
end
