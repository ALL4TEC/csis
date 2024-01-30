# frozen_string_literal: true

class WebhookController < ApplicationController
  skip_before_action :verify_authenticity_token

  def sellsy
    logger.debug "Sellsy WebHook Input : #{request.body.read}"
  end

  def securecodebox
    data = request.body.read
    logger.info 'Received securecodebox data'
    logger.debug "SecurecodeBox Webhook Input: #{data}"
    # Check remote_ip is from cluster
    if PrivateIpValidator.local_cluster_request_origin?(request.remote_ip)
      json_content = JSON.parse(data)
      # Retrieve ScanLaunch
      scan_launch_id = Scb::ScanResultMapper.find_scan_launch_id(json_content)
      scan_launch = ScanLaunch.find(scan_launch_id)
      # Update related job status
      scan_launch.job.update!(status: :completed)
      # Attach data to retrieved ScanLaunch and update status to trigger import
      ReportScanLaunchService.save_scan_launch_data(scan_launch, data)
      # Trigger import if auto_import
      scan_launch.update!(status: :done, terminated_at: Time.zone.now)
    end
  rescue StandardError => e
    logger.error(e.message)
  ensure
    head :ok
  end
end
