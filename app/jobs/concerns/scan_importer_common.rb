# frozen_string_literal: true

module ScanImporterCommon
  extend ActiveSupport::Concern

  included do
    private

    def perform(report_scan_import)
      creator = report_scan_import.scan_import.importer
      job_h = {
        progress_steps: 6,
        subscribers: report_scan_import.report.project.staffs
      }
      job_h[:creator] = creator if creator.present?
      handle_perform(job_h, :update_scan_import, report_scan_import.scan_import) do |job|
        import_type = report_scan_import.scan_import.import_type
        logger.debug "#{import_type} Import Job started for report: #{report_scan_import.report}"
        scanner_service.new(job).send(:import_scans, report_scan_import)
        logger.debug "#{import_type} import for report #{report_scan_import.report}: OK"
        job.update!(status: :completed)
      end
    end

    def update_scan_import(scan_import)
      scan_import.update(status: :failed)
    end

    # method to override per importer job
    def scanner_service
      raise NotImplementedError
    end
  end
end
