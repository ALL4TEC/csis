# frozen_string_literal: true

require 'test_helper'

module Schedulers
  class Scb::PrepareJobTest < ActiveJob::TestCase
    test 'prepare job with last report_action and existing project report' do
      # GIVEN
      # A scheduled scan with report_action = last
      # linked to a project with an existing report
      scheduled_scan = scheduled_scans(:scheduled_scan_two)
      assert scheduled_scan.last_report_action?
      project = scheduled_scan.project
      assert project.reports.count.positive?
      reports_count = project.reports.count
      last_report = project.last_report('ScanReport')
      # WHEN
      # calling PrepareJob
      assert_enqueued_with(job: Launchers::Scb::ZaproxyScanJob) do
        Schedulers::Scb::PrepareJob.perform_now(scheduled_scan)
      end
      # THEN
      # no new report is created
      # but a new scan_launch is linked to last project report
      # with same scan_configuration as scheduled_scan
      project.reload
      assert_equal reports_count, project.reports.count
      last_scan_launch = last_report.scan_launches.order(created_at: :desc).last
      assert_equal last_scan_launch.scan_configuration, scheduled_scan.scan_configuration
    end

    test 'prepare job with last report_action and no project report' do
      # GIVEN
      # A scheduled scan with report_action = last
      # linked to a project with no report
      scheduled_scan = scheduled_scans(:scheduled_scan_two)
      assert scheduled_scan.last_report_action?
      project = scheduled_scan.project
      project.reports = []
      assert project.reports.count.zero?
      # WHEN
      # calling PrepareJob
      assert_enqueued_with(job: Launchers::Scb::ZaproxyScanJob) do
        Schedulers::Scb::PrepareJob.perform_now(scheduled_scan)
      end
      # THEN
      # a new report is created
      # and a new scan_launch is linked to new project report
      # with same scan_configuration as scheduled_scan
      project.reload
      assert_equal 1, project.reports.count
      last_scan_launch = project.last_report('ScanReport').scan_launches
                                .order(created_at: :desc).last
      assert_equal last_scan_launch.scan_configuration, scheduled_scan.scan_configuration
    end

    test 'prepare job with new report_action and existing project report' do
      # GIVEN
      # A scheduled scan with report_action = new
      # linked to a project with an existing report
      scheduled_scan = scheduled_scans(:scheduled_scan_one)
      assert scheduled_scan.new_report_action?
      project = scheduled_scan.project
      assert project.reports.count.positive?
      reports_count = project.reports.count
      # WHEN
      # calling PrepareJob
      assert_enqueued_with(job: Launchers::Scb::ZaproxyScanJob) do
        Schedulers::Scb::PrepareJob.perform_now(scheduled_scan)
      end
      # THEN
      # a new report is created
      # and a new scan_launch is linked to last project report
      # with same scan_configuration as scheduled_scan
      project.reload
      assert_equal reports_count + 1, project.reports.count
      last_scan_launch = project.last_report('ScanReport').scan_launches
                                .order(created_at: :desc).last
      assert_equal last_scan_launch.scan_configuration, scheduled_scan.scan_configuration
    end

    test 'prepare job with new report_action and no project report' do
      # GIVEN
      # A scheduled scan with report_action = new
      # linked to a project with no report
      scheduled_scan = scheduled_scans(:scheduled_scan_one)
      assert scheduled_scan.new_report_action?
      project = scheduled_scan.project
      project.reports = []
      assert project.reports.count.zero?
      # WHEN
      # calling PrepareJob
      assert_enqueued_with(job: Launchers::Scb::ZaproxyScanJob) do
        Schedulers::Scb::PrepareJob.perform_now(scheduled_scan)
      end
      # THEN
      # a new report is created
      # and a new scan_launch is linked to new project report
      # with same scan_configuration as scheduled_scan
      project.reload
      assert_equal 1, project.reports.count
      last_scan_launch = project.last_report('ScanReport').scan_launches
                                .order(created_at: :desc).last
      assert_equal last_scan_launch.scan_configuration, scheduled_scan.scan_configuration
    end
  end
end
