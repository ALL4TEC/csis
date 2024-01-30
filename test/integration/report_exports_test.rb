# frozen_string_literal: true

require 'test_helper'

class ReportExportsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'unauthenticated cannot list report exports' do
    get report_exports_path(scan_reports(:mapui))
    check_not_authenticated
  end

  test 'authenticated staff can list report exports' do
    sign_in users(:staffuser)
    r = scan_reports(:mapui)
    get report_exports_path(r)
    assert_select 'main table.table' do
      ReportExport.where(report: r).page(1).each do |exp|
        assert_select 'td', text: I18n.l(exp.created_at, format: :long)
        assert_select 'td', text: exp.exporter.to_s
      end
    end
  end

  test 'authenticated staff can delete report-export' do
    sign_in users(:staffuser)
    export = report_exports(:report_export_one)
    delete export_path(export)
    assert_equal I18n.t('exports.notices.deleted'), flash[:notice]
  end

  test 'authenticated staff cannot delete non-existent report-export' do
    sign_in users(:staffuser)
    delete export_path('ABC')
    assert_redirected_to projects_path
  end

  test 'unauthenticated cannot delete report-export' do
    export = report_exports(:report_export_one)
    delete export_path(export)
    check_not_authenticated
  end

  test 'authenticated staff can create report-export' do
    sign_in users(:staffuser)
    r = scan_reports(:mapui)
    post report_exports_path(r, format: :pdf), params: { archi: 'false', histo: 'false' }
    assert_redirected_to report_exports_path(r)
  end

  test 'authenticated staff can export report aggregates' do
    sign_in users(:staffuser)
    r = scan_reports(:mapui)
    post report_exports_path(r, format: :xlsx)
    assert_redirected_to report_exports_path(r)
  end
end
