# frozen_string_literal: true

require 'application_system_test_case'

class ReportExportsTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  include ActiveJob::TestHelper

  test 'report job scheduling' do
    staff = users(:staffuser)
    I18n.with_locale(staff.language.iso) do
      sign_in staff
      report = reports(:mapui)
      visit projects_path
      visit project_path(report.project)
      visit project_reports_path(report.project)
      visit report_path(report)
      assert_enqueued_with(job: ScanReportGeneratorJob) do
        click_on I18n.t('reports.actions.export')
      end
    end
  end
end
