# frozen_string_literal: true

require 'test_helper'

module Importers
  class Scb::ZaproxyImportJobTest < ActiveJob::TestCase
    test 'Scb::Zaproxy scan import in error is correctly handled' do
      scan_launch = scan_launches(:scan_launch_two) # Launched by staffuser for mapui
      scan_import = ScanImport.create!(
        importer: users(:staffuser), status: :scheduled, import_type: :zaproxy,
        scan_launch: scan_launch
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
      Scb::ZaproxyImportJob.perform_now(report_scan_import)
      assert_equal 'failed', scan_import.status
    end
  end
end
