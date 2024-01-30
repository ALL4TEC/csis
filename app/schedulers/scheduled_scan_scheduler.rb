# frozen_string_literal: true

module ScheduledScanScheduler
  extend ActiveSupport::Concern

  included do
    has_many :crons,
      class_name: 'Cron',
      dependent: :delete_all,
      as: :cronable

    def scheduled_scan_cron
      crons.find_by(name: scheduled_scan_name) if scan_configuration.present?
    end

    def scheduled_scan_cron=(value)
      cron_data = {
        cronable_id: id,
        cronable_type: 'ScheduledScan',
        name: scheduled_scan_name
      }
      self.tmp_scheduled_scan_cron = Cron.find_or_create_by(cron_data)
      tmp_scheduled_scan_cron.update!(value: value)
    end

    def scheduled_scan_name
      "scheduled_scan_#{project}_#{scanner}_#{scan_type}_#{target}"
    end

    private

    def scheduled_scan_cron_presence
      return true if tmp_scheduled_scan_cron.present?

      errors.add(:scheduled_scan_cron, 'must be present !')
    end

    # If set_schedule is passed the name of an existing schedule, that schedule is updated.
    def schedule_scheduled_scan
      schedule_name = scheduled_scan_name
      config = {
        class: 'ActiveJob::QueueAdapters::ResqueAdapter::JobWrapper',
        args: {
          job_class: 'Schedulers::Scb::PrepareJob',
          queue_name: 'default',
          priority: nil,
          arguments: [self]
        },
        cron: scheduled_scan_cron&.value,
        queue: 'default',
        persist: true,
        description: "Scan launch for #{schedule_name}"
      }
      Resque.set_schedule(schedule_name, config)
      ScheduledJob.find_or_create_by!(name: schedule_name) do |scheduled_job|
        scheduled_job.configuration = config
      end
    end

    def remove_scheduled_scan_schedule
      Resque.remove_schedule(scheduled_scan_name)
    end

    def handle_scheduled_scan_schedule
      if scheduled_scan_cron.present?
        schedule_scheduled_scan
      else
        remove_scheduled_scan_schedule
      end
    end
  end
end
