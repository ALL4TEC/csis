# frozen_string_literal: true

require 'test_helper'

class ReportServiceTest < ActiveJob::TestCase
  test 'that handle_occurrences does not reuse occurrences among created aggregates' do
    # GIVEN
    # A project with auto_generation
    project = projects(:project_auto)
    project.reports
    # 1 previous report with 2 aggregates linked to 4 occurrences
    assert_equal 1, project.reports.count
    previous_report = project.reports.last
    create_fake_vm_data(previous_report)
    previous_vm_o = previous_report.vm_occurrences
    previous_vm_o_vuln_ids = previous_vm_o.map(&:vulnerability_id).uniq
    create_fake_wa_data(previous_report)
    previous_wa_o = previous_report.wa_occurrences
    previous_wa_o_vuln_ids = previous_wa_o.map(&:vulnerability_id).uniq

    # => duplication of 2 aggregates
    # 2 occurrences left for 2 new aggregates if not similar (= not linked to same vulnerability)
    new_report = Report.create!(
      project: project, staff: User.staffs.first, title: "#{project} new",
      edited_at: Time.zone.now, contacts: project.client.contacts.limit(5)
    )

    # NEW REPORT VM
    vm_o1 = create_fake_vm_occurrence(previous_vm_o_vuln_ids.first)
    vm_o2 = create_fake_vm_occurrence(previous_vm_o_vuln_ids.second)
    # Same vuln id for 2 last => only one aggregate created
    similar_vuln_id = link_occ_to_unused_vulnerability(previous_vm_o_vuln_ids)
    vm_o3 = create_fake_vm_occurrence(similar_vuln_id)
    vm_o4 = create_fake_vm_occurrence(similar_vuln_id)
    vm_o = [vm_o1, vm_o2, vm_o3, vm_o4]
    assert_equal(2, previous_vm_o.count { |occ| occ.similar?(vm_o1) })
    assert_equal(2, previous_vm_o.count { |occ| occ.similar?(vm_o2) })
    assert_equal(0, previous_vm_o.count { |occ| occ.similar?(vm_o3) })
    assert_equal(0, previous_vm_o.count { |occ| occ.similar?(vm_o4) })
    new_vm_scan = create_fake_vm_scan([vm_o1, vm_o2, vm_o3, vm_o4])
    new_report.vm_scans << new_vm_scan
    new_report.save!

    # NEW REPORT WA
    wa_o1 = create_fake_wa_occurrence(previous_wa_o_vuln_ids.first)
    wa_o2 = create_fake_wa_occurrence(previous_wa_o_vuln_ids.second)
    unused_vuln_id1 = link_occ_to_unused_vulnerability(previous_wa_o_vuln_ids)
    unused_vuln_id2 = link_occ_to_unused_vulnerability(previous_wa_o_vuln_ids + [unused_vuln_id1])
    wa_o3 = create_fake_wa_occurrence(unused_vuln_id1)
    wa_o4 = create_fake_wa_occurrence(unused_vuln_id2)
    wa_o = [wa_o1, wa_o2, wa_o3, wa_o4]
    assert_equal(2, previous_wa_o.count { |occ| occ.similar?(wa_o1) })
    assert_equal(2, previous_wa_o.count { |occ| occ.similar?(wa_o2) })
    assert_equal(0, previous_wa_o.count { |occ| occ.similar?(wa_o3) })
    assert_equal(0, previous_wa_o.count { |occ| occ.similar?(wa_o4) })
    new_wa_scan = create_fake_wa_scan([wa_o1, wa_o2, wa_o3, wa_o4])
    new_report.wa_scans << new_wa_scan
    new_report.save!

    # WHEN
    # Calling handle_occurrences with those occurrences passed as parameter
    ReportService.handle_occurrences(new_report, previous_report, vm_o, wa_o)
    # THEN
    assert_vm(new_report, vm_o1, vm_o2, vm_o3, vm_o4)
    assert_wa(new_report, wa_o1, wa_o2, wa_o3, wa_o4)
  end

  private

  def assert_vm(new_report, vm_o1, vm_o2, vm_o3, vm_o4)
    # 2 aggregates are created in duplication of 2 aggregates from previous report
    assert_equal 4, new_report.vm_occurrences.count
    assert_equal 3, new_report.aggregates.vms.count
    new_agg1 = new_report.aggregates.vms.find { |agg| vm_o1.in?(agg.vm_occurrences) }
    assert_equal [vm_o1], new_agg1.vm_occurrences.to_a
    new_agg2 = new_report.aggregates.vms.find { |agg| vm_o2.in?(agg.vm_occurrences) }
    assert_equal [vm_o2], new_agg2.vm_occurrences.to_a
    # And 1 new aggregate is created linked to only 2 remaining similar occurrences
    new_agg3 = new_report.aggregates.vms.find { |agg| vm_o3.in?(agg.vm_occurrences) }
    assert_equal [], [vm_o3.id, vm_o4.id] - new_agg3.vm_occurrences.pluck(:id)
  end

  def assert_wa(new_report, wa_o1, wa_o2, wa_o3, wa_o4)
    # 2 aggregates are created in duplication of 2 aggregates from previous report
    assert_equal 4, new_report.wa_occurrences.count
    assert_equal 4, new_report.aggregates.was.count
    new_agg1 = new_report.aggregates.was.find { |agg| wa_o1.in?(agg.wa_occurrences) }
    assert_equal [wa_o1], new_agg1.wa_occurrences.to_a
    new_agg2 = new_report.aggregates.was.find { |agg| wa_o2.in?(agg.wa_occurrences) }
    assert_equal [wa_o2], new_agg2.wa_occurrences.to_a
    # And 2 new aggregates are created linked to 2 remaining occurrences
    new_agg3 = new_report.aggregates.was.find { |agg| wa_o3.in?(agg.wa_occurrences) }
    assert_equal [wa_o3], new_agg3.wa_occurrences.to_a
    new_agg4 = new_report.aggregates.was.find { |agg| wa_o4.in?(agg.wa_occurrences) }
    assert_equal [wa_o4], new_agg4.wa_occurrences.to_a
  end

  def link_occ_to_unused_vulnerability(used_vuln_ids)
    Vulnerability.all.where.not(id: used_vuln_ids).first.id
  end

  def create_fake_vm_data(previous_report)
    # 4 new occurrences coming from new scan with 2 similar to 2 from previous
    prev_vm_o1 = create_fake_vm_occurrence(Vulnerability.first.id)
    prev_vm_o2 = create_fake_vm_occurrence(Vulnerability.first.id)
    prev_vm_o3 = create_fake_vm_occurrence(Vulnerability.second.id)
    prev_vm_o4 = create_fake_vm_occurrence(Vulnerability.second.id)
    # Link occurrences to vm_scan
    prev_vm_scan = create_fake_vm_scan([prev_vm_o1, prev_vm_o2, prev_vm_o3, prev_vm_o4])
    previous_report.vm_scans << prev_vm_scan
    prev_agg1 = create_fake_vm_aggregate(previous_report, 1, [prev_vm_o1, prev_vm_o2])
    prev_agg2 = create_fake_vm_aggregate(previous_report, 2, [prev_vm_o3, prev_vm_o4])
    previous_report.aggregates << [prev_agg1, prev_agg2]
    previous_report.save!
  end

  def create_fake_wa_data(previous_report)
    # 4 new occurrences coming from new scan with 2 similar to 2 from previous
    prev_wa_o1 = create_fake_wa_occurrence(Vulnerability.first.id)
    prev_wa_o2 = create_fake_wa_occurrence(Vulnerability.first.id)
    prev_wa_o3 = create_fake_wa_occurrence(Vulnerability.second.id)
    prev_wa_o4 = create_fake_wa_occurrence(Vulnerability.second.id)
    # Link occurrences to wa_scan
    prev_wa_scan = create_fake_wa_scan([prev_wa_o1, prev_wa_o2, prev_wa_o3, prev_wa_o4])
    previous_report.wa_scans << prev_wa_scan
    prev_agg1 = create_fake_wa_aggregate(previous_report, 1, [prev_wa_o1, prev_wa_o2])
    prev_agg2 = create_fake_wa_aggregate(previous_report, 2, [prev_wa_o3, prev_wa_o4])
    previous_report.aggregates << [prev_agg1, prev_agg2]
    previous_report.save!
  end

  def create_fake_vm_scan(occs_ary)
    VmScan.create!(
      reference: "RefX#{SecureRandom.hex(10)}",
      scan_type: 'Type',
      status: 'State',
      name: 'Scan 1',
      launched_by: 'User',
      duration: '00:11:11',
      launched_at: '2150-04-23T00:00:00Z',
      occurrences: occs_ary
    )
  end

  def create_fake_wa_scan(occs_ary)
    WaScan.create!(
      reference: SecureRandom.hex(10),
      scan_type: 'scheduled',
      launched_at: Time.zone.now,
      name: 'some scan',
      status: 'FINISHED',
      occurrences: occs_ary
    )
  end

  def create_fake_vm_aggregate(report, rank, occs_ary)
    Aggregate.create!(
      report: report, title: "title#{rank}", severity: 1, status: 1, kind: 0, rank: rank,
      vm_occurrences: occs_ary
    )
  end

  def create_fake_wa_aggregate(report, rank, occs_ary)
    Aggregate.create!(
      report: report, title: "title#{rank}", severity: 1, status: 1, kind: 1, rank: rank,
      wa_occurrences: occs_ary
    )
  end

  def create_fake_vm_occurrence(vuln_id)
    VmOccurrence.create!(
      scan: VmScan.first,
      vulnerability: Vulnerability.find(vuln_id)
    )
  end

  def create_fake_wa_occurrence(vuln_id)
    WaOccurrence.create!(
      scan: WaScan.first,
      vulnerability: Vulnerability.find(vuln_id)
    )
  end
end
