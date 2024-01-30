# frozen_string_literal: true

require 'test_helper'

class ScanReportsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def run
    Whois.stub(:whois, nil) do
      super
    end
  end

  test 'unauthenticated cannot create new scan report' do
    project = projects(:project_one)
    get new_project_scan_report_path(project)
    check_not_authenticated
    post project_scan_reports_path(project)
    check_not_authenticated
  end

  test 'unauthenticated cannot consult scan report' do
    report = scan_reports(:mapui)
    get scan_report_path(report)
    check_not_authenticated
  end

  test 'unauthenticated cannot consult non-existent scan report' do
    get scan_report_path('ABC')
    check_not_authenticated
  end

  test 'unauthenticated cannot edit scan report' do
    report = scan_reports(:mapui)
    get edit_scan_report_path(report)
    check_not_authenticated
    put scan_report_path(report)
    check_not_authenticated
    patch scan_report_path(report)
    check_not_authenticated
  end

  test 'unauthenticated cannot edit non-existent scan report' do
    report_id = 'ABC'
    get edit_scan_report_path(report_id)
    check_not_authenticated
    put scan_report_path(report_id)
    check_not_authenticated
    patch scan_report_path(report_id)
    check_not_authenticated
  end

  test 'authenticated staff can consult scan report' do
    sign_in users(:staffuser)
    report = scan_reports(:mapui)
    get scan_report_path(report)
    assert_response :success
  end

  test 'authenticated staff cannot consult non-existent scan report' do
    sign_in users(:staffuser)
    get scan_report_path('ABC')
    assert_redirected_to projects_path
  end

  test 'authenticated staff can view new scan report form' do
    sign_in users(:staffuser)
    project = projects(:project_one)
    get new_project_scan_report_path(project)
    assert_response :success
  end

  test 'authenticated staff can create new scan report' do
    sign_in users(:staffuser)
    report = Report.first
    title = 'New Report'
    post project_scan_reports_path(report.project), params:
    {
      scan_report:
      {
        title: title,
        edited_at: '2230-06-05',
        contact_ids: [User.contacts.first.id]
      }
    }
    new_report = Report.find_by(title: title)
    assert_redirected_to new_report
  end

  test 'new scan report can be created from any report in analyst scope, by default previous
        but if base_report_id is not selected then nothing will be duplicated' do
    sign_in users(:staffuser)
    vms = vm_scans(:vm_scan_one).id
    # was = wa_scans(:two)
    targ = targets(:target_one).id
    title = 'New Report'
    project = projects(:project_two)
    post project_scan_reports_path(project), params:
    {
      scan_report:
      {
        title: title,
        edited_at: '2230-06-05',
        contact_ids: [User.contacts.first.id],
        vm_scan_ids: [''] << vms,
        target_ids: [targ] # ,
        # wa_scan_ids: [''] << was.id,      # Did not get why it raises an error
        # "#{was.id}": was.web_app_url
      }
    }
    new_report = ScanReport.find_by(title: title)
    assert_redirected_to new_report
    # Nothing was duplicated as no base_report
    new_report.aggregates.count.zero?
  end

  test 'new scan report can be created from any report in analyst scope, by default previous
        thus if occurrences are present, aggregates are duplicated on report creation' do
    sign_in users(:staffuser)
    previous_report = scan_reports(:mapui2)
    vms = vm_scans(:vm_scan_one).id
    # was = wa_scans(:two)
    targ = targets(:target_one).id
    title = 'New Report'
    # We only check duplication no auto aggregation
    previous_report.project.update(auto_aggregate: false)
    post project_scan_reports_path(previous_report.project), params:
    {
      scan_report:
      {
        title: title,
        edited_at: '2230-06-05',
        base_report_id: previous_report.id,
        contact_ids: [User.contacts.first.id],
        vm_scan_ids: [''] << vms,
        target_ids: [targ] # ,
        # wa_scan_ids: [''] << was.id,      # Did not get why it raises an error
        # "#{was.id}": was.web_app_url
      }
    }
    new_report = ScanReport.find_by(title: title)
    assert_redirected_to new_report
    # Aggregates of new report were duplicated from previous report
    new_report.aggregates.each do |a|
      assert_not_nil previous_report.aggregates.find_by(title: a.title)
    end
  end

  test 'new scan report can be created from any report in analyst scope
        thus if occurrences are present, aggregates are duplicated on report creation' do
    sign_in users(:staffuser)
    base_report = scan_reports(:mapui2)
    vms = vm_scans(:vm_scan_one).id
    # was = wa_scans(:two)
    targ = targets(:target_one).id
    title = 'New Report'
    project = projects(:project_two)
    project.update(auto_aggregate: false) # We only check duplication no auto aggregation
    post project_scan_reports_path(project), params:
    {
      scan_report:
      {
        title: title,
        edited_at: '2230-06-05',
        base_report_id: base_report.id,
        contact_ids: [User.contacts.first.id],
        vm_scan_ids: [''] << vms,
        target_ids: [targ] # ,
        # wa_scan_ids: [''] << was.id,      # Did not get why it raises an error
        # "#{was.id}": was.web_app_url
      }
    }
    new_report = ScanReport.find_by(title: title)
    assert_redirected_to new_report
    # Aggregates of new report were duplicated from previous report
    new_report.aggregates.each do |a|
      assert_not_nil base_report.aggregates.find_by(title: a.title)
    end
  end

  test 'new scan report can be created and auto aggregation only includes occurrences related
        to selected ones' do
    # GIVEN
    # 2 vm_scans with 2 targets each with occurrences:
    # Target 1: 1.2.3.4
    # Target 2: 10.0.1.3
    # Target 3: 192.168.1.1
    # Target 4: 172.0.0.1
    # a report with 2 vm_scans with only 1 out of 2 targets selected each
    # related to a project with auto_aggregation
    sign_in users(:staffuser)
    # Using predefined vm_scans
    scan1 = vm_scans(:vm_scan_one)
    scan2 = vm_scans(:vm_scan_two)
    scan1.update(occurrences: [])
    scan2.update(occurrences: [])
    scan_ids = ['', scan1.id, scan2.id]
    # Resetting all occurrences and targets for test
    ip1 = '1.2.3.4'
    ip2 = '10.0.1.3'
    ip3 = '192.168.1.1'
    ip4 = '172.0.0.1'
    target1 = Target.create!(kind: 'VmTarget', name: ip1, ip: ip1)
    Target.create!(kind: 'VmTarget', name: 'vmt2', ip: ip2)
    target3 = Target.create!(kind: 'VmTarget', name: ip3, ip: ip3)
    Target.create!(kind: 'VmTarget', name: 'vm4', ip: ip4)
    vm_occ1 = VmOccurrence.create!(
      scan: scan1, vulnerability: vulnerabilities(:vulnerability_one), ip: ip1
    )
    assert_equal vm_occ1.target, target1
    VmOccurrence.create!(scan: scan1, vulnerability: vulnerabilities(:vulnerability_two), ip: ip2)
    vm_occ3 = VmOccurrence.create!(
      scan: scan2, vulnerability: vulnerabilities(:vulnerability_three), ip: ip3
    )
    assert_equal vm_occ3.target, target3
    VmOccurrence.create!(scan: scan2, vulnerability: vulnerabilities(:vulnerability_four), ip: ip4)
    target_ids = ['', target1.id, target3.id]
    title = 'New Report'
    project = projects(:project_two)
    assert project.auto_aggregate?
    # WHEN
    # creating report
    post project_scan_reports_path(project), params:
    {
      scan_report:
      {
        title: title,
        edited_at: '2230-06-05',
        contact_ids: [User.contacts.first.id],
        vm_scan_ids: scan_ids,
        target_ids: target_ids
      }
    }
    # THEN
    # Only the occurrences related to selected targets are used for aggregation
    new_report = ScanReport.find_by(title: title)
    assert_redirected_to new_report
    # Aggregates of new report are only composed of occurrences of selected targets, not others
    assert_equal new_report.aggregates.count, 2
    # Only occurrences related to targets 1 and 3
    assert_equal 1, new_report.aggregates.first.vm_occurrences.count
    assert new_report.aggregates.first.vm_occurrences.first.in?([vm_occ1, vm_occ3])
    assert_equal 1, new_report.aggregates.last.vm_occurrences.count
    assert new_report.aggregates.last.vm_occurrences.first.in?([vm_occ1, vm_occ3])
  end

  test 'authenticated staff can display edit form for scan report' do
    sign_in users(:staffuser)
    report = scan_reports(:mapui)
    get edit_scan_report_path(report)
    assert_response :success
  end

  test 'authenticated staff cannot display edit form for non-existent scan report' do
    sign_in users(:staffuser)
    get edit_scan_report_path('ABC')
    assert_redirected_to projects_path
  end

  test 'authenticated staff can update scan report' do
    sign_in users(:staffuser)
    report = scan_reports(:mapui)
    payload = {
      title: 'Joli Scan',
      edited_at: Date.new,
      vm_scan_ids: [VmScan.first.id],
      contact_ids: [User.contacts.first.id]
    }
    put scan_report_path(report), params:
    {
      scan_report: payload
    }
    updated = ScanReport.find(report.id)
    assert_equal payload[:title], updated.title
    assert_equal payload[:edited_at], updated.edited_at
    assert_equal payload[:vm_scan_ids], updated.vm_scans.ids
  end

  test 'authenticated staff cannot update report scan without title' do
    sign_in users(:staffuser)
    report = scan_reports(:mapui)
    put scan_report_path(report), params:
    {
      scan_report:
      {
        title: nil
      }
    }
    updated = ScanReport.find(report.id)
    assert_equal report.title, updated.title
  end

  test 'authenticated staff cannot update report scan without contact' do
    sign_in users(:staffuser)
    report = scan_reports(:mapui)
    put scan_report_path(report), params:
    {
      scan_report:
      {
        contact_ids: []
      }
    }
    updated = ScanReport.find(report.id)
    assert_equal report.contacts.ids, updated.contacts.ids
  end

  test 'authenticated staff cannot update report scan with more than 5 contact' do
    sign_in users(:staffuser)
    report = scan_reports(:mapui)
    put scan_report_path(report), params:
    {
      scan_report:
      {
        contact_ids: User.contacts.all.ids
      }
    }
    updated = ScanReport.find(report.id)
    assert_equal report.contacts.ids, updated.contacts.ids
  end

  test 'authenticated staff cannot update non-existent scan report' do
    sign_in users(:staffuser)
    put scan_report_path('ABC'), params: {
      scan_report: {}
    }
    assert_redirected_to projects_path
  end

  test 'after report scan creation, aggregates still have progressive rank' do
    sign_in users(:staffuser)
    project = Project.first
    r = ScanReport.create!(title: 'Previous Report', staff: User.staffs.first, project: project,
      edited_at: Date.new(2230, 1, 1), contact_ids: [User.contacts.first.id])
    Aggregate.create!(report: r, title: 'keep1', severity: 1, status: 1, kind: 1, rank: 1,
      vm_occurrences: [vm_occurrences(:vm_occurrence_one)])
    Aggregate.create!(report: r, title: 'do not keep', severity: 1, status: 1, kind: 1, rank: 2,
      vm_occurrences: [vm_occurrences(:vm_occurrence_two)])
    Aggregate.create!(report: r, title: 'keep2', severity: 1, status: 1, kind: 1, rank: 3,
      vm_occurrences: [vm_occurrences(:vm_occurrence_three)])
    title = 'New Report'
    post project_scan_reports_path(project), params:
    {
      scan_report:
      {
        title: title,
        edited_at: '2230-06-05',
        vm_scan_ids: [vm_scans(:vm_scan_one).id],
        target_ids: [targets(:target_one).id],
        contact_ids: [User.contacts.first.id]
      }
    }
    r = ScanReport.find_by(title: title).aggregates.where(kind: 1).order('rank DESC')
                  .pluck(:rank)
    prev = r.count + 1
    r.each do |i|
      assert_equal i + 1, prev
      prev = i
    end
  end
end
