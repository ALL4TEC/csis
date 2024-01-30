# frozen_string_literal: true

require 'test_helper'

class VerifyAutoGenerationJobTest < ActiveJob::TestCase
  UPDATED_REF = 'updated_ref'

  test 'job runs with a wa scan' do
    scan = wa_scans(:wa_scan_auto)
    assert_equal 0, scan.reports.count
    VerifyAutoGenerationJob.perform_now(scan)
    assert_equal 1, scan.reports.count
  end

  test 'job runs with a vm scan' do
    scan = vm_scans(:vm_scan_auto)
    assert_equal 0, scan.reports.count
    VerifyAutoGenerationJob.perform_now(scan)
    assert_equal 1, scan.reports.count
  end

  test 'auto aggregation is done if scan is linked to report_scan_import with auto_aggregate' do
    # Create new scan linked to auto_aggregate report_import
    report_scan_import = report_scan_imports(:report_scan_import_one)
    created_vm_scan = VmScan.create!(
      import_id: report_scan_import.import_id,
      launched_at: Time.zone.now,
      duration: Time.zone.now.utc.strftime('%H:%M:%S'),
      reference: 'some ref',
      scan_type: 'NESSUS',
      name: 'Sometitle',
      status: 'Finished',
      target: 'something'
    )
    ReportService.stub(:auto_aggregate_occurrences, mock_auto(created_vm_scan)) do
      VerifyAutoGenerationJob.perform_now(created_vm_scan)
    end
    assert_equal created_vm_scan.reference, UPDATED_REF
  end

  private

  def mock_auto(scan)
    scan.update!(reference: UPDATED_REF)
  end
end
