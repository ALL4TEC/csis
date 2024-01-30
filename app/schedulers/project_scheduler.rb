# frozen_string_literal: true

module ProjectScheduler
  extend ActiveSupport::Concern

  included do
    has_many :crons,
      class_name: 'Cron',
      dependent: :delete_all,
      as: :cronable

    def report_auto_generation_cron
      crons.find_by(name: report_auto_generation_name)
    end

    def report_auto_generation_cron=(value)
      cron_data = {
        cronable_id: id,
        cronable_type: 'Project',
        name: report_auto_generation_name
      }
      self.tmp_report_auto_generation_cron = Cron.find_or_create_by(cron_data)
      tmp_report_auto_generation_cron.update!(value: value)
    end

    def report_auto_generation_name
      "report_auto_generation_for_project_#{name}"
    end

    private

    def report_auto_generation_cron_presence
      return true unless auto_generate? && tmp_report_auto_generation_cron.blank?

      errors.add(:report_auto_generation_cron, 'must be present !')
    end

    # If set_schedule is passed the name of an existing schedule, that schedule is updated.
    def schedule_report_auto_generation
      schedule_name = report_auto_generation_name
      config = {
        class: 'ActiveJob::QueueAdapters::ResqueAdapter::JobWrapper',
        args: {
          job_class: 'Generators::AutoGenerateReportJob',
          queue_name: 'default',
          priority: nil,
          arguments: [id]
        },
        cron: report_auto_generation_cron.value,
        queue: 'default',
        persist: true,
        description: "Report auto generation for #{name}"
      }
      Resque.set_schedule(schedule_name, config)
      ScheduledJob.find_or_create_by!(name: schedule_name) do |scheduled_job|
        scheduled_job.configuration = config
      end
    end

    def remove_report_auto_generation_schedule
      Resque.remove_schedule(report_auto_generation_name)
    end
  end
end
