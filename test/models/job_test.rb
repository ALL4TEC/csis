# frozen_string_literal: true

require 'test_helper'

class JobTest < ActiveSupport::TestCase
  test 'update job status triggers progress_step update unless error' do
    job_hash = {
      resque_job_id: 'something',
      status: :init,
      clazz: MailDeliveryJob,
      progress_step: 0,
      progress_steps: 2
    }
    job = Job.create!(job_hash)
    assert_equal 2, job.progress_steps
    assert_equal 0, job.progress_step
    assert_equal 'init', job.status
    job.update(status: :generating_file)
    assert_equal 1, job.progress_step
    job.update(status: :generating_file)
    assert_equal 1, job.progress_step
    job.update(status: :error)
    assert_equal 1, job.progress_step
    job.update(status: :completed)
    assert_equal 2, job.progress_step
  end
end
