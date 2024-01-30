# frozen_string_literal: true

require 'test_helper'

class ReportScanImportsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'unauthenticated cannot view report imports page' do
    get report_scan_imports_path(Report.first)
    check_not_authenticated
  end

  test 'authenticated staff can view report imports page' do
    staff = users(:staffuser)
    sign_in staff
    get report_scan_imports_path(staff.staff_viewable_reports.first)
    assert_response :success
  end

  test 'unauthenticated cannot view new report import form' do
    get new_report_scan_import_path(Report.first)
    check_not_authenticated
  end

  test 'authenticated staff can view new report import form' do
    staff = users(:staffuser)
    sign_in staff
    get new_report_scan_import_path(staff.staff_viewable_reports.first)
    assert_response :success
  end

  test 'unauthenticated cannot import a scan' do
    post report_scan_imports_path(Report.first)
    check_not_authenticated
  end

  test 'authenticated staff can import a scan from burp' do
    staff = users(:staffuser)
    report = staff.staff_viewable_reports.first
    sign_in staff
    post report_scan_imports_path(report), params: {
      scan_import: {
        import_type: 'burp',
        report_scan_import_attributes: {
          document: fixture_file_upload('JobTestValues/burp_issues.xml', xml_mime),
          scan_name: 'somename',
          auto_aggregate: false,
          auto_aggregate_mixing: false
        }
      }
    }
    assert_redirected_to report_scan_imports_path(report)
  end

  test 'authenticated staff can import a scan from nessus' do
    staff = users(:staffuser)
    report = staff.staff_viewable_reports.first
    sign_in staff
    post report_scan_imports_path(report), params: {
      scan_import: {
        import_type: 'nessus',
        report_scan_import_attributes: {
          document: fixture_file_upload('JobTestValues/nessus_export.xml', xml_mime),
          scan_name: 'somename',
          auto_aggregate: false,
          auto_aggregate_mixing: false
        }
      }
    }
    assert_redirected_to report_scan_imports_path(report)
  end

  test 'authenticated staff can import a scan from with_secure' do
    staff = users(:staffuser)
    report = staff.staff_viewable_reports.first
    sign_in staff
    post report_scan_imports_path(report), params: {
      scan_import: {
        import_type: 'with_secure',
        report_scan_import_attributes: {
          document: fixture_file_upload('LibTestValues/with_secure_sample_vm_scan.xml', xml_mime),
          scan_name: 'somename',
          auto_aggregate: false,
          auto_aggregate_mixing: false
        }
      }
    }
    assert_redirected_to report_scan_imports_path(report)
  end

  test 'authenticated staff can import a scan from zaproxy' do
    staff = users(:staffuser)
    report = staff.staff_viewable_reports.first
    sign_in staff
    post report_scan_imports_path(report), params: {
      scan_import: {
        import_type: 'zaproxy',
        report_scan_import_attributes: {
          document: fixture_file_upload('JobTestValues/zaproxy_alerts.json', json_mime),
          scan_name: 'somename',
          auto_aggregate: false,
          auto_aggregate_mixing: false
        }
      }
    }
    assert_redirected_to report_scan_imports_path(report)
  end

  test 'authenticated staff can import a scan with auto_aggregate fields' do
    staff = users(:staffuser)
    report = staff.staff_viewable_reports.first
    sign_in staff
    post report_scan_imports_path(report), params: {
      scan_import: {
        import_type: 'zaproxy',
        report_scan_import_attributes: {
          document: fixture_file_upload('JobTestValues/zaproxy_alerts.json', json_mime),
          scan_name: 'somename',
          auto_aggregate: true,
          auto_aggregate_mixing: false
        }
      }
    }
    assert_redirected_to report_scan_imports_path(report)
  end

  test 'unauthenticated cannot delete report import' do
    delete scan_import_path(ScanImport.first)
    check_not_authenticated
  end

  test 'report import can be deleted by destructor job if contains scans' do
    scan_import = scan_imports(:scan_import_one) # No scan
    import_id = scan_import.id
    report = scan_import.report
    assert scan_import.vm_scans.blank?
    assert scan_import.wa_scans.blank?
    # Add one vm scan to import
    VmScan.create!(
      reference: 'RefX',
      scan_type: 'Type',
      status: 'State',
      name: 'Scan 1',
      launched_by: 'User',
      duration: '00:11:11',
      launched_at: '2150-04-23T00:00:00Z',
      import_id: import_id
    )
    scan_import.reload
    assert scan_import.vm_scans.present?
    report = scan_import.report
    sign_in users(:staffuser)
    assert_enqueued_with(job: DestructorJob) do
      delete scan_import_path(scan_import)
      assert_redirected_to report_scan_imports_path(report)
      assert ScanImport.find(import_id).present? # delayed job
    end
  end

  test 'report import can be deleted inline if no scan linked' do
    scan_import = scan_imports(:scan_import_one) # No scan
    import_id = scan_import.id
    report = scan_import.report
    assert scan_import.vm_scans.blank?
    assert scan_import.wa_scans.blank?
    sign_in users(:staffuser)
    delete scan_import_path(scan_import)
    assert_redirected_to report_scan_imports_path(report)
    assert_raises ActiveRecord::RecordNotFound do
      ScanImport.find(import_id)
    end
  end

  test 'do not raise an unhandled exception when scan import has no name' do
    staff = users(:staffuser)
    report = staff.staff_viewable_reports.first
    sign_in staff
    post report_scan_imports_path(report), params: {
      scan_import: {
        import_type: 'zaproxy',
        report_scan_import_attributes: {
          document: fixture_file_upload('JobTestValues/zaproxy_alerts.json', json_mime),
          scan_name: '',
          auto_aggregate: false,
          auto_aggregate_mixing: false
        }
      }
    }
    assert_response 200
  end
end
