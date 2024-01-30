# frozen_string_literal: true

require 'test_helper'

class ReportsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def run
    Whois.stub(:whois, nil) do
      super
    end
  end

  test 'unauthenticated cannot list project reports' do
    project = projects(:project_one)
    get project_reports_path(project)
    check_not_authenticated
  end

  test 'unauthenticated cannot delete project report' do
    report = scan_reports(:mapui)
    delete report_path(report)
    check_not_authenticated
    # Check that report still exists
    scan_reports(:mapui)
  end

  test 'unauthenticated cannot delete non-existent report' do
    delete report_path('ABC')
    check_not_authenticated
  end

  test 'authenticated staff can list project reports' do
    sign_in users(:staffuser)
    project = projects(:project_one)
    get project_reports_path(project)
    assert_response :success
  end

  test 'authenticated staff can delete project report' do
    sign_in users(:staffuser)
    report = scan_reports(:mapui)
    project = report.project
    delete report_path(report)
    assert_redirected_to project_reports_path(project)
    # Check that report was only discarded, not actually destroyed
    Report.trashed.find(report.id)
  end

  test 'authenticated staff can regenerate_scoring project report' do
    sign_in users(:staffuser)
    report = scan_reports(:mapui)
    put regenerate_scoring_report_path(report)
    assert_redirected_to report
  end

  test 'authenticated staff cannot delete non-existent project report' do
    sign_in users(:staffuser)
    delete report_path('ABC')
    assert_redirected_to projects_path
  end

  test 'authenticated staff can restore discarded project report' do
    sign_in users(:staffuser)
    report = scan_reports(:mapui)
    report.discard
    put restore_report_path(report)
    assert_redirected_to report
  end

  test 'authenticated staff cannot restore non-existent discarded project report' do
    sign_in users(:staffuser)
    put restore_report_path('ABC')
    assert_redirected_to projects_path
  end

  test 'authenticated staff can export classic report' do
    sign_in users(:staffuser)
    report = scan_reports(:mapui)
    post report_exports_path(report, format: :pdf)
    assert_equal I18n.t('exports.notices.generating'), flash[:notice]
  end

  test 'unauthenticated cannot export classic report' do
    report = scan_reports(:mapui)
    post report_exports_path(report)
    check_not_authenticated
  end

  test 'authenticated staff can export without architecture report' do
    sign_in users(:staffuser)
    report = scan_reports(:mapui)
    post report_exports_path(report, format: :pdf), params:
      {
        archi: false
      }
    assert_equal I18n.t('exports.notices.generating'), flash[:notice]
  end

  test 'unauthenticated cannot export without architecture report' do
    report = scan_reports(:mapui)
    post report_exports_path(report), params:
      {
        archi: false
      }
    check_not_authenticated
  end

  test 'unauthenticated cannot see all reports' do
    get reports_path
    assert_redirected_to login_url
  end

  test 'authenticated contact can see all of his reports' do
    sign_in users(:c_one)
    get reports_path
    assert_response(200)
  end

  test 'authenticated staff can see all his related reports' do
    sign_in users(:staffuser)
    get reports_path
    assert_response(200)
  end
end
