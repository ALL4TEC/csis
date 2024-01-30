# frozen_string_literal: true

class ApplicationKubeJob < ApplicationJob
  include KubeJob

  private

  # @param job_h: Must specify creator, subscribers, and progress_steps in job_h
  # @param failure_callback is called when rescuing StandardError with failure_callback_args
  def handle_perform(job_h, failure_callback = nil, failure_callback_args = nil)
    job_h1 = { resque_job_id: job_id, status: :init, clazz: self.class, progress_step: 0 }
    job_h1.merge!(job_h)
    job = Job.create!(job_h1)
    yield job
  rescue StandardError => e
    send(failure_callback, failure_callback_args) if failure_callback.present?
    logger.error "#{self.class} failed: #{e.message}"
    job.update!(status: :error, stacktrace: format_stacktrace(e)) if job.present?
    raise e if Rails.env.in?(%w[development])
  end

  def format_stacktrace(exception)
    exception.full_message
  end
end
