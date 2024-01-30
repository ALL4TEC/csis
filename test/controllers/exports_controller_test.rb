# frozen_string_literal: true

require 'test_helper'

class ExportsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActiveJob::TestHelper

  test 'report pdf job scheduling' do
    sign_in users(:staffuser)
    report = scan_reports(:mapui)
    assert_enqueued_with(job: Generators::ScanReportGeneratorJob) do
      post report_exports_path(report, format: :pdf), params:
      {
        archi: false
      }
    end
    assert_equal I18n.t('exports.notices.generating'), flash[:notice]
  end

  test 'report xlsx job scheduling' do
    sign_in users(:staffuser)
    report = scan_reports(:mapui)
    assert_enqueued_with(job: Generators::XlsxReportAggregatesGeneratorJob) do
      post report_exports_path(report, format: :xlsx)
    end
    assert_equal I18n.t('exports.notices.generating'), flash[:notice]
  end
end
