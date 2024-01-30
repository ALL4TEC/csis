# frozen_string_literal: true

module Schedulers
  class StoredJobs
    class << self
      def reschedule
        ScheduledJob.all.find_each do |scheduled_job|
          scheduled_job.configuration[:persist] = true # lost when calling configuration.save
          Resque.set_schedule(scheduled_job.name, scheduled_job.configuration)
        end
      end

      def clear
        Resque.schedule.each { |schedule| Resque.remove_schedule(schedule[0]) }
      end
    end
  end
end
