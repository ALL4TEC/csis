# frozen_string_literal: true

require 'test_helper'

class ScansTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'unauthenticated cannot see vm_scans' do
    get vm_scan_path(VmScan.first)
    check_not_authenticated
  end

  test 'unauthenticated cannot see wa_scans' do
    get wa_scan_path(WaScan.first)
    check_not_authenticated
  end

  test 'authenticated staff only can see vm_scans' do
    sign_in users(:c_one)
    scan = vm_scans(:vm_scan_one)
    get vm_scan_path(scan)
    check_not_authorized
    delete logout_path
    sign_in users(:staffuser)
    get vm_scan_path(scan)
    assert_response :success
  end

  test 'authenticated staff only can see wa_scans' do
    sign_in users(:c_one)
    scan = wa_scans(:wa_scan_one)
    get wa_scan_path(scan)
    check_not_authorized
    delete logout_path
    sign_in users(:staffuser)
    get wa_scan_path(scan)
    assert_response :success
  end

  test 'unauthenticated cannot see vm_occurrence modal' do
    scan = vm_scans(:vm_scan_one)
    occurrence = scan.occurrences.first
    get occurrence_vm_scan_path(scan, occurrence)
    check_unauthorized
  end

  test 'unauthenticated cannot see wa_occurrence modal' do
    scan = wa_scans(:wa_scan_one)
    occurrence = scan.occurrences.first
    get occurrence_wa_scan_path(scan, occurrence)
    check_unauthorized
  end

  test 'authenticated staff only can see vm_occurrence modal' do
    scan = vm_scans(:vm_scan_one)
    occurrence = scan.occurrences.first
    sign_in users(:c_one)
    get occurrence_vm_scan_path(scan, occurrence)
    check_not_authorized
    delete logout_path
    sign_in users(:staffuser)
    get occurrence_vm_scan_path(scan, occurrence)
    assert_response :success
  end

  test 'authenticated staff only can see wa_occurrence modal' do
    scan = wa_scans(:wa_scan_one)
    occurrence = scan.occurrences.first
    sign_in users(:c_one)
    get occurrence_wa_scan_path(scan, occurrence)
    check_not_authorized
    delete logout_path
    sign_in users(:staffuser)
    get occurrence_wa_scan_path(scan, occurrence)
    assert_response :success
  end

  test 'authenticated staff with no related scanner account can see vm_occurrence modal
    of staff_viewable_reports_vm_scans' do
    # GIVEN
    # A user with no related scanner account (in a new team with another user with several
    # related scans)
    # but some staff_viewable_reports_vm_scans (from mapui report)
    # In same new team
    team = Team.create!(name: 'New Team')
    staff2 = users(:staffuser)
    staff2.staff_teams << team
    staff2.save!
    staff = User.new(full_name: 'New User', email: 'someemail@somewhere.com')
    staff.groups << Group.staff
    staff.staff_teams << team
    staff.users_groups.first.current = true
    staff.save!
    assert staff.staff_viewable_reports_vm_scans.count.zero?
    report = staff2.staff_viewable_reports.first
    # Modify report.project teams to add new one
    report.project.update!(teams: [team])
    sign_in staff2
    scan_import = ScanImport.create!(
      importer: staff2, status: :scheduled, import_type: :nessus
    )
    attachment = {
      io: File.open('test/fixtures/files/JobTestValues/nessus_export.xml'),
      filename: 'nessus_export.xml',
      content_type: 'application/xml',
      identify: false
    }
    report_scan_import = ReportScanImport.create!(
      report: report, scan_import: scan_import, scan_name: 'mapui vm',
      document: attachment
    )
    Importers::NessusImportJob.perform_now(report_scan_import)
    assert_equal 'completed', scan_import.status
    staff.reload
    assert staff.staff_viewable_reports_vm_scans.count.positive?
    assert ScanService.visible_accounts_scans_ids(staff, :vm).count.zero?
    # WHEN Fetching vm_occurrence detail
    scan = staff.staff_viewable_reports_vm_scans.first
    get occurrence_vm_scan_path(scan, scan.occurrences.first)
    # THEN it's ok
    assert_response :success
  end

  test 'authenticated staff with no related scanner account can see wa_occurrence modal
    of staff_viewable_reports_wa_scans' do
    # A user with no related scanner account (in a new team with another user with several
    # related scans)
    # but some staff_viewable_reports_vm_scans (from mapui report)
    # In same new team
    team = Team.create!(name: 'New Team')
    staff2 = users(:staffuser)
    staff2.staff_teams << team
    staff2.save!
    staff = User.new(full_name: 'New User', email: 'someemail@somewhere.com')
    staff.groups << Group.staff
    staff.staff_teams << team
    staff.users_groups.first.current = true
    staff.save!
    assert staff.staff_viewable_reports_wa_scans.count.zero?
    report = staff2.staff_viewable_reports.first
    # Modify report.project teams to add new one
    report.project.update!(teams: [team])
    sign_in staff2
    scan_import = ScanImport.create!(
      importer: staff2, status: :scheduled, import_type: :burp
    )
    attachment = {
      io: File.open('test/fixtures/files/JobTestValues/burp_issues.xml'),
      filename: 'burp_issues.xml',
      content_type: 'application/xml',
      identify: false
    }
    report_scan_import = ReportScanImport.create!(
      report: report, scan_import: scan_import, scan_name: 'mapui wa',
      document: attachment
    )
    Importers::BurpIssuesImportJob.perform_now(report_scan_import)
    assert_equal 'completed', scan_import.status
    staff.reload
    assert staff.staff_viewable_reports_wa_scans.count.positive?
    assert ScanService.visible_accounts_scans_ids(staff, :wa).count.zero?
    # WHEN Fetching wa_occurrence detail
    scan = staff.staff_viewable_reports_wa_scans.first
    get occurrence_wa_scan_path(scan, scan.occurrences.first)
    # THEN it's ok
    assert_response :success
  end

  test 'project usable vm scans with no related scanner account' do
    # GIVEN
    # A project with no related scanner account
    # but some vm_scans (from mapui report)
    staff = users(:staffuser)
    project = projects(:project_one)
    report = scan_reports(:mapui)
    sign_in staff
    # Adding a vm_scan to report
    scan_import = ScanImport.create!(
      importer: staff, status: :scheduled, import_type: :nessus
    )
    attachment = {
      io: File.open('test/fixtures/files/JobTestValues/nessus_export.xml'),
      filename: 'nessus_export.xml',
      content_type: 'application/xml',
      identify: false
    }
    report_scan_import = ReportScanImport.create!(
      report: report, scan_import: scan_import, scan_name: 'mapui vm',
      document: attachment
    )
    Importers::NessusImportJob.perform_now(report_scan_import)
    assert_equal 'completed', scan_import.status
    # Removing all accounts
    Account.destroy_all
    project.reload
    assert ScanService.common_accounts_scans_between_teams(project.teams, :vm).count.zero?
    assert project.vm_scans.count.positive?
    # WHEN Fetching project.usable_vm_scans THEN ok
    assert_equal(project.usable_vm_scans.count, project.vm_scans.count)
    assert project.usable_vm_scans.find(project.vm_scans.first)
  end

  test 'project usable wa scans with no related scanner account' do
    # GIVEN
    # A project with no related scanner account
    # but some wa_scans (from mapui report)
    staff = users(:staffuser)
    project = projects(:project_one)
    report = scan_reports(:mapui)
    sign_in staff
    # Adding a vm_scan to report
    scan_import = ScanImport.create!(
      importer: staff, status: :scheduled, import_type: :nessus
    )
    attachment = {
      io: File.open('test/fixtures/files/JobTestValues/nessus_export.xml'),
      filename: 'nessus_export.xml',
      content_type: 'application/xml',
      identify: false
    }
    report_scan_import = ReportScanImport.create!(
      report: report, scan_import: scan_import, scan_name: 'mapui wa',
      document: attachment
    )
    Importers::NessusImportJob.perform_now(report_scan_import)
    assert_equal 'completed', scan_import.status
    # Removing all accounts
    Account.destroy_all
    project.reload
    assert ScanService.common_accounts_scans_between_teams(project.teams, :wa).count.zero?
    assert project.wa_scans.count.positive?
    # WHEN Fetching project.usable_wa_scans THEN ok
    assert_equal(project.usable_wa_scans.count, project.wa_scans.count)
    assert project.usable_wa_scans.find(project.wa_scans.first)
  end
end
