# frozen_string_literal: true

module Schedulers
  class Scb::PrepareService
    def initialize(scheduled_scan)
      @scheduled_scan = scheduled_scan
    end

    # Create a new scan_launch from scheduled_scan.scan_configuration and attach to wanted
    # report
    def prepare
      report = handle_report
      scan_launch = ScanLaunch.create!(
        scan_configuration: @scheduled_scan.scan_configuration,
        report: report
      )
      scanner = @scheduled_scan.scanner.capitalize
      "Launchers::Scb::#{scanner}ScanJob".constantize.perform_later(scan_launch)
    end

    private

    # In case there is no previous report but last was selected, we create a new one too
    def handle_report
      project = @scheduled_scan.project
      creator = @scheduled_scan.launcher
      report = project.last_report('ScanReport') if @scheduled_scan.last_report_action?
      if report.blank?
        today = Time.zone.now
        report = Report.create!(
          project: project, staff: creator, title: "#{project} #{today}",
          edited_at: today, contacts: project.client.contacts.limit(5)
        )
      end
      report
    end
  end
end
