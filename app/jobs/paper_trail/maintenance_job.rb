# frozen_string_literal: true

# PaperTrail maintenance job
# Handle new partition creation per month
# and partition deletion
# + destroy all useless notifications and jobs
class PaperTrail::MaintenanceJob < ApplicationKubeJob
  def perform
    logger.debug 'PaperTrail maintenance Job started'
    PaperTrail::MaintenanceService.manage_partitions
    logger.debug 'PaperTrail maintenance Job completed'
    logger.debug 'Cleaning notifications'
    Cleaners::NotificationCleaner.clear_all
    logger.debug 'Notifications cleaned'
    logger.debug 'Cleaning jobs'
    Cleaners::JobCleaner.clear_all
    logger.debug 'Jobs cleaned'
  rescue StandardError => e
    logger.error "PaperTrail maintenance failed : #{e.message}"
  end
end
