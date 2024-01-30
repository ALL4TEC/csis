# frozen_string_literal: true

require 'test_helper'

class Importers::WithSecureJobTest < ActiveJob::TestCase
  test 'WithSecure scan report is correctly imported' do
    scan_import = ScanImport.create!(
      importer: users(:staffuser), status: :scheduled, import_type: :with_secure
    )
    attachment = {
      io: File.open('test/fixtures/files/LibTestValues/with_secure_sample_vm_scan.xml'),
      filename: 'with_secure_sample_vm_scan.xml',
      content_type: 'application/xml',
      identify: false
    }
    report_scan_import = ReportScanImport.create!(
      report: scan_reports(:mapui), scan_import: scan_import, scan_name: 'somename',
      auto_aggregate: true,
      auto_aggregate_mixing: true,
      document: attachment
    )
    report_scan_import.report.vm_occurrences.each(&:destroy)
    occs = report_scan_import.report.vm_occurrences
    assert_equal 0, occs.count
    Importers::WithSecureImportJob.perform_now(report_scan_import)
    report_scan_import.report.reload
    occs.reload
    assert_equal 'completed', scan_import.status
    assert_equal 2046, occs.count
    Vulnerability.kinds.each_key do |kind_k|
      kind_count = occs.count { |occ| occ.vulnerability.kind == kind_k }
      assert kind_count.positive?
    end
  end

  test 'WithSecure scan import in error is correctly handled' do
    scan_import = ScanImport.create!(
      importer: users(:staffuser), status: :scheduled, import_type: :with_secure
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
    Importers::WithSecureImportJob.perform_now(report_scan_import)
    assert_equal 'failed', scan_import.status
  end
end
