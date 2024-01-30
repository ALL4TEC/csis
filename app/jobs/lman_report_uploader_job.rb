# frozen_string_literal: true

# Upload instance report to lman
class LmanReportUploaderJob < ApplicationKubeJob
  def perform
    job_h = {
      progress_steps: 1
    }
    handle_perform(job_h) do |job|
      Rails.logger.info('Uploading instance report to Lman...')
      report = [
        {
          name: 'projects',
          value: {
            count: Project.with_discarded.kept.count,
            discarded: Project.with_discarded.discarded.count
          }
        },
        {
          name: 'staffs',
          value: {
            count: User.staffs.with_discarded.kept.count,
            discarded: User.staffs.with_discarded.discarded.count
          }
        }
      ]
      Rails.logger.info('Report ready')
      response = Faraday.post(
        "#{ENV.fetch('LMAN_ROOT')}/api/v1/instances",
        { csis: report }.to_json,
        'Content-Type' => 'application/json',
        'Accept' => 'application/json',
        'Authorization' => "Bearer #{Rails.application.credentials.jwt}"
      )
      Rails.logger.info("Report uploaded with status: #{response.status}")
      if response.status != 200
        Rails.logger.error(response.headers)
        Rails.logger.error(response.body)
      end
      job.update(status: :completed)
      response
    end
  end
end
