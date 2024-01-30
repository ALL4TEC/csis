# frozen_string_literal: true

require 'test_helper'
require 'utils/cloners/scan_cloner'

module Generators
  class AutoGenerateReportTest < ActiveJob::TestCase
    include ScanCloner

    test 'job runs with only a wa scan' do
      project = projects(:project_auto)
      vm_scans(:vm_scan_auto).destroy
      # Update wa_scan launched_at to be more recent than project.report.edited_at
      wa_scans(:wa_scan_auto).update!(launched_at: 1.week.ago)
      assert_equal 1, project.reports.count
      AutoGenerateReportJob.perform_now(project.id)
      project.reload
      assert_equal 2, project.reports.count
    end

    test 'job runs with only a vm scan' do
      project = projects(:project_auto)
      wa_scans(:wa_scan_auto).destroy
      # Update wa_scan launched_at to be more recent than project.report.edited_at
      vm_scans(:vm_scan_auto).update!(launched_at: 1.week.ago)
      assert_equal 1, project.reports.count
      AutoGenerateReportJob.perform_now(project.id)
      project.reload
      assert_equal 2, project.reports.count
    end

    test 'New report is generated with multiple new scans even if no previous report' do
      # GIVEN
      # A project with auto report generation
      # Without an existing report
      project = projects(:project_auto)
      project.reports.delete_all
      assert_equal 0, project.reports.count
      # And there are 2 scans matching regex
      # linked to WaTarget target_wa_one and target_auto (vm)
      scan_vm = vm_scans(:vm_scan_auto)
      scan_wa = wa_scans(:wa_scan_auto)
      assert_equal [], scan_vm.targets - [targets(:target_auto)]
      assert_equal [], scan_wa.targets - [targets(:target_wa_one)]
      new_scans = [scan_vm, scan_wa]
      new_scans.each do |scan|
        assert_equal 0, scan.reports.count
        assert scan.name.match(project.scan_regex)
        # Each with only one occurrence
        assert 1, scan.occurrences.count
      end
      # duplicated occurrences for last assertions
      duplicated_vm_occ = scan_vm.occurrences.first
      duplicated_wa_occ = scan_wa.occurrences.first
      # WHEN
      # time has come to auto generate
      AutoGenerateReportJob.perform_now(project.id)
      # THEN
      # A new report is created
      project.reload
      assert_equal 1, project.reports.count
      new_scans.each do |scan|
        scan.reload
        assert_equal 1, scan.reports.count
      end
      # One aggregate is created per occurrence with auto_aggregation by qid per kind
      assert_equal project.report.aggregates.count, 2
      # Each aggregate corresponds to related scan occurrence
      vm_aggregates = project.report.aggregates.select { |agg| agg.vm_occurrences.count.positive? }
      wa_aggregates = project.report.aggregates.select { |agg| agg.wa_occurrences.count.positive? }
      assert_equal 1, vm_aggregates.count
      assert_equal 1, wa_aggregates.count
      assert_equal 1, vm_aggregates.first.vm_occurrences.count
      assert_equal 1, wa_aggregates.first.wa_occurrences.count
      assert_equal vm_aggregates.first.vm_occurrences.first, duplicated_vm_occ
      assert_equal wa_aggregates.first.wa_occurrences.first, duplicated_wa_occ

      # SO THEN WE EDIT PREVIOUS DATA TO HAVE
      # GIVEN
      # A project with auto report generation
      # With an existing report with edited_at < new scans.launched_at
      project.reports.first.update!(edited_at: 2.months.ago)
      project.reload
      # And 4 scans matching regex
      # Each with one occurrence same as clone source
      # + Another one
      # vm_scan1: occ1->vuln1 + occ2->vuln2
      # vm_scan2: occ1->vuln1 + occ2->vuln2
      # wa_scan1: occ1->vuln3 + occ2->vuln4
      # wa_scan2: occ1->vuln3 + occ2->vuln4
      new_vm_scan_one = clone_vm_scan_and_add_vuln_two(scan_vm)
      new_vm_scan_two = clone_vm_scan_and_add_vuln_two(scan_vm)
      new_wa_scan_one = clone_wa_scan_and_add_vuln_two(scan_wa)
      new_wa_scan_two = clone_wa_scan_and_add_vuln_two(scan_wa)
      new_vm_scans = [new_vm_scan_one, new_vm_scan_two]
      new_wa_scans = [new_wa_scan_one, new_wa_scan_two]
      new_scans = new_vm_scans + new_wa_scans
      new_scans.each do |scan|
        assert_equal 0, scan.reports.count
        assert scan.name.match(project.scan_regex)
        assert(scan.launched_at > project.report.edited_at)
        # Each with only 2 occurrences => 8 occurrences
        assert 2, scan.occurrences.count
      end
      # WHEN
      # time has come to auto generate
      AutoGenerateReportJob.perform_now(project.id)
      # THEN
      # A new report is created
      project.reload
      assert_equal 2, project.reports.count
      new_scans.each do |scan|
        scan.reload
        assert_equal 1, scan.reports.count
      end

      # Occurrences copy leads to:
      # 2 occurrences duplicated for 2 vm scans into same aggregate
      # 2 occurrences duplicated for 2 wa scans into same aggregate
      # 2 occurrences with same qid auto aggregated for 2 vm scans
      # 2 occurrences with same qid auto aggregated for 2 wa scans
      # One aggregate is created per occurrence with auto_aggregation by qid per kind
      assert_equal 4, project.report.aggregates.count
      # Each aggregate corresponds to related scan occurrence
      vm_aggregates = project.report.aggregates.select { |agg| agg.vm_occurrences.count.positive? }
      wa_aggregates = project.report.aggregates.select { |agg| agg.wa_occurrences.count.positive? }
      assert_equal 2, vm_aggregates.count
      assert_equal 2, wa_aggregates.count
      new_vm_scans_occurrences = new_vm_scans.flat_map(&:occurrences)
      new_wa_scans_occurrences = new_wa_scans.flat_map(&:occurrences)
      # All new scans occurrences have been used in new report
      assert_empty vm_aggregates.flat_map(&:vm_occurrences) - new_vm_scans_occurrences
      assert_empty wa_aggregates.flat_map(&:wa_occurrences) - new_wa_scans_occurrences
      # Duplicated
      vuln_id_associated_to_duplicated_vm_occ = duplicated_vm_occ.vulnerability_id
      vuln_id_associated_to_duplicated_wa_occ = duplicated_wa_occ.vulnerability_id
      occs_similar_to_duplicated_vm_occ = new_vm_scans_occurrences.select do |occ|
        occ.vulnerability_id == vuln_id_associated_to_duplicated_vm_occ
      end
      assert_equal 2, occs_similar_to_duplicated_vm_occ.count
      duplicated_vm_agg = vm_aggregates.find do |agg|
        agg.vm_occurrences.all? do |occ|
          occ.vulnerability_id == vuln_id_associated_to_duplicated_vm_occ
        end
      end
      assert_equal 2, duplicated_vm_agg.vm_occurrences.count
      occs_similar_to_duplicated_wa_occ = new_wa_scans_occurrences.select do |occ|
        occ.vulnerability_id == vuln_id_associated_to_duplicated_wa_occ
      end
      assert_equal 2, occs_similar_to_duplicated_wa_occ.count
      duplicated_wa_agg = wa_aggregates.find do |agg|
        agg.wa_occurrences.all? do |occ|
          occ.vulnerability_id == vuln_id_associated_to_duplicated_wa_occ
        end
      end
      assert_equal 2, duplicated_wa_agg.wa_occurrences.count
      # Auto aggregated
      remaining_vm_occs = new_vm_scans_occurrences - occs_similar_to_duplicated_vm_occ
      remaining_wa_occs = new_wa_scans_occurrences - occs_similar_to_duplicated_wa_occ
      assert_equal 2, remaining_vm_occs.count
      assert_equal 2, remaining_wa_occs.count
      vuln_id_linked_to_remaining_vm_occs = remaining_vm_occs.first.vulnerability_id
      vuln_id_linked_to_remaining_wa_occs = remaining_wa_occs.first.vulnerability_id
      assert remaining_vm_occs.all? do |occ|
        occ.vulnerability_id == vuln_id_linked_to_remaining_vm_occs
      end
      assert remaining_wa_occs.all? do |occ|
        occ.vulnerability_id == vuln_id_linked_to_remaining_wa_occs
      end
      remaining_new_vm_agg = vm_aggregates - [duplicated_vm_agg]
      remaining_new_wa_agg = wa_aggregates - [duplicated_wa_agg]
      expected_new_vm_agg = vm_aggregates.find do |agg|
        agg.vm_occurrences.all? do |occ|
          occ.vulnerability_id == vuln_id_linked_to_remaining_vm_occs
        end
      end
      assert_equal remaining_new_vm_agg.first, expected_new_vm_agg
      expected_new_wa_agg = wa_aggregates.find do |agg|
        agg.wa_occurrences.all? do |occ|
          occ.vulnerability_id == vuln_id_linked_to_remaining_wa_occs
        end
      end
      assert_equal remaining_new_wa_agg.first, expected_new_wa_agg
    end
  end
end
