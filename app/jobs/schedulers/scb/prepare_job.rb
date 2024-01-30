# frozen_string_literal: true

# Job launching zaproxy wa scans
module Schedulers
  class Scb::PrepareJob < ApplicationKubeJob
    def perform(scheduled_scan)
      creator = scheduled_scan.launcher
      job_h = {
        progress_steps: 1
      }
      job_h[:creator] = creator if creator.present?
      handle_perform(job_h) do |job|
        logger.debug "Prepare Job started for scheduled scan: #{scheduled_scan}"
        Schedulers::Scb::PrepareService.new(scheduled_scan).prepare
        logger.debug "Prepare Job for scheduled scan #{scheduled_scan}: OK"
        job.update!(status: :completed)
      end
    end
  end
end
