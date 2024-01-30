# frozen_string_literal: true

module Generators
  # Job using previous report to create new one automatically
  class AutoGenerateReportJob < ApplicationKubeJob
    private

    def perform(project_id)
      job_h = {
        progress_steps: 1
      }
      handle_perform(job_h) do |job|
        ReportAutoGeneratorService.generate(project_id)
        job.update!(status: :completed)
        logger.debug "#{self.class} : OK"
      end
    end
  end
end
