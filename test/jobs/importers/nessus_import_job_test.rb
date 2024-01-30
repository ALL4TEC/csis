# frozen_string_literal: true

require 'test_helper'

class Importers::NessusImportJobTest < ActiveJob::TestCase
  test 'Nessus scan is correctly imported' do
    scan_import = ScanImport.create!(
      importer: users(:staffuser), status: :scheduled, import_type: :nessus
    )
    attachment = {
      io: File.open('test/fixtures/files/JobTestValues/nessus_export.xml'),
      filename: 'nessus_export.xml',
      content_type: 'application/xml',
      identify: false
    }
    report_scan_import = ReportScanImport.create!(
      report: scan_reports(:mapui), scan_import: scan_import, scan_name: 'somename',
      document: attachment
    )
    Importers::NessusImportJob.perform_now(report_scan_import)
    assert_equal 'completed', scan_import.status
  end

  test 'Nessus scan import in error is correctly handled' do
    scan_import = ScanImport.create!(
      importer: users(:staffuser), status: :scheduled, import_type: :nessus
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
    Importers::NessusImportJob.perform_now(report_scan_import)
    assert_equal 'failed', scan_import.status
  end
end
