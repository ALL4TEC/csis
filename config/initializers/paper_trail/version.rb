# frozen_string_literal: true

module PaperTrail
  class Version < ActiveRecord::Base
    include PaperTrail::VersionConcern
    range_partition_by :created_at

    class << self
      # Ransack
      def ransackable_attributes(_auth_object = nil)
        %w[created_at event id item_id item_type object object_changes whodunnit]
      end

      def ransackable_associations(_auth_object = nil)
        %w[item]
      end

      def schedule_maintenance
        schedule_name = 'paper_trail_maintenance'
        config = {
          class: 'ActiveJob::QueueAdapters::ResqueAdapter::JobWrapper',
          args: {
            job_class: 'PaperTrail::MaintenanceJob',
            queue_name: 'default',
            priority: nil,
            arguments: []
          },
          cron: '0 1 * * *',
          queue: 'default',
          persist: true,
          description: 'Maintenance job for paper trail versions'
        }
        Resque.set_schedule(schedule_name, config)
        ScheduledJob.find_or_create_by!(name: schedule_name) do |scheduled_job|
          scheduled_job.configuration = config
        end
      end

      def partition_name_for(day)
        "versions_y#{day.year}_m#{"%02d" % day.month}"
      end
    end
  end
end
