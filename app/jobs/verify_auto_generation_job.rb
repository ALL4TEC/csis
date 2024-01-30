# frozen_string_literal: true

# Job creating new report automatically if new vulnerability found
class VerifyAutoGenerationJob < ApplicationKubeJob
  private

  def perform(scan)
    job_h = {
      subscribers: scan.readers,
      progress_steps: 1
    }
    handle_perform(job_h) do |job|
      logger.debug "VerifyAutoGeneration Job started for: #{scan}"

      if (scan_import = scan.scan_import).present? &&
         (report_scan_import = scan_import.report_scan_import).present? &&
         report_scan_import.auto_aggregate?
        ReportService.auto_aggregate_occurrences(
          report_scan_import.report, nil, nil, report_scan_import.auto_aggregate_mixing
        )
      else
        ProjectService.auto_generate_report_for_exceeding_threshold_occurrences(scan)
      end

      logger.debug 'VerifyAutoGeneration Job : OK'
      job.update(status: :completed)
    end
  end
end
