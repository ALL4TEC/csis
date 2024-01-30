# frozen_string_literal: true

require 'test_helper'
require 'utils/cloners/scan_cloner'

class FakeVersion
  DATA = {
    item_type: 'Occurrence',
    event: 'create',
    whodunnit: nil,
    object: nil,
    created_at: Time.zone.now,
    object_changes: nil,
    item_id: SecureRandom.uuid
  }.freeze

  def last
    PaperTrail::Version.new(DATA.merge(id: SecureRandom.random_number(999_999_999)))
  end

  def reset
    nil
  end
end

class ProjectServiceTest < ActiveJob::TestCase
  include ScanCloner

  test 'that auto_generate_report_for_exceeding_threshold_occurrences is generated if
        no previous report and if previous report for wa scan' do
    WaOccurrence.any_instance.stubs(:versions).returns(FakeVersion.new)
    vulnerabilities(:vulnerability_two).update!(severity: 3)
    # GIVEN
    # a project with no previous scanreport
    # with auto_generate true
    # with a scan regex
    # and a severity threshold
    project = projects(:project_auto)
    project.reports.delete_all
    assert_equal 0, project.reports.count
    # WHEN
    # a new scan matching appears with occurrences exceeding severity threshold
    scan = wa_scans(:wa_scan_auto)
    assert_equal 0, scan.reports.count
    VerifyAutoGenerationJob.perform_now(scan)
    # THEN
    # a new report is created, with only auto aggregated new occurrences as no previous report
    project.reload
    assert_equal 1, scan.reports.count
    assert_equal 1, project.reports.count
    # Only 1 occurrence is in scan, auto aggregated in one aggregate
    assert_equal project.report.aggregates.count, 1
    assert_equal project.report.aggregates.first.wa_occurrences, scan.occurrences
    # WHEN
    # another new scan matching appears with occurrences exceeding severity threshold
    new_scan = clone_wa_scan_and_add_vuln_two(scan)
    project.reports.first.update!(edited_at: 2.months.ago)
    VerifyAutoGenerationJob.perform_now(new_scan)
    # THEN
    # a new report is created, with copied common occurrences between new and previous report
    # and auto aggregated for the rest
    project.reload
    assert_equal 1, new_scan.reports.count
    assert_equal 2, project.reports.count
    # Only 1 occurrence is in scan, auto aggregated in one aggregate
    # + one aggregate per new occurrence
    assert_equal project.report.aggregates.count, 2
    assert_empty(project.report.aggregates.flat_map(&:wa_occurrences) - new_scan.occurrences)
  end

  test 'that auto_generate_report_for_exceeding_threshold_occurrences is generated if
        no previous report and if previous report for vm scan' do
    VmOccurrence.any_instance.stubs(:versions).returns(FakeVersion.new)
    # Update vulnerability two severity to exceed threshold
    vulnerabilities(:vulnerability_two).update!(severity: 3)
    # GIVEN
    # a project with no previous scanreport
    # with auto_generate true
    # with a scan regex
    # and a severity threshold
    project = projects(:project_auto)
    project.reports.delete_all
    assert_equal 0, project.reports.count
    # WHEN
    # a new scan matching appears with occurrences exceeding severity threshold
    scan = vm_scans(:vm_scan_auto)
    assert_equal 0, scan.reports.count
    VerifyAutoGenerationJob.perform_now(scan)
    # THEN
    # a new report is created, with only auto aggregated new occurrences as no previous report
    project.reload
    assert_equal 1, scan.reports.count
    assert_equal 1, project.reports.count
    # Only 1 occurrence is in scan, auto aggregated in one aggregate
    assert_equal 1, project.report.aggregates.count
    assert_equal project.report.aggregates.first.vm_occurrences, scan.occurrences
    # WHEN
    # another new scan matching appears with occurrences exceeding severity threshold
    new_scan = clone_vm_scan_and_add_vuln_two(scan)
    project.reports.first.update!(edited_at: 2.months.ago)
    VerifyAutoGenerationJob.perform_now(new_scan)
    # THEN
    # a new report is created, with copied common occurrences between new and previous report
    # and auto aggregated for the rest
    project.reload
    new_scan.reload
    assert_equal 1, new_scan.reports.count
    assert_equal 2, project.reports.count
    # 2 occurrences in new_scan => 1 duplicated
    # + one in a new aggregate
    assert_equal 2, project.report.aggregates.count
    assert_empty(project.report.aggregates.flat_map(&:vm_occurrences) - new_scan.occurrences)
  end
end
