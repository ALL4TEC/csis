# frozen_string_literal: true

require 'test_helper'

class JobCleanerTest < ActiveSupport::TestCase
  test 'clear all' do
    # GIVEN
    # a notification older than 5 days
    # and a recent job
    given
    # WHEN
    # calling Cleaners::JobCleaner.clear_all
    Cleaners::JobCleaner.clear_all
    # THEN
    # only the recent job is kept
    assert_equal 1, Job.all.count
    assert Job.last.created_at > 5.days.ago
  end

  private

  def given
    Job.all.destroy_all
    recent_job_hash = {
      resque_job_id: 'something',
      status: :init,
      clazz: MailDeliveryJob,
      progress_step: 0,
      progress_steps: 2,
      created_at: 4.days.ago
    }
    old_job_hash = {
      resque_job_id: 'something',
      status: :init,
      clazz: MailDeliveryJob,
      progress_step: 0,
      progress_steps: 2,
      created_at: 6.days.ago
    }
    Job.create!(recent_job_hash)
    Job.create!(old_job_hash)
    assert_equal 2, Job.all.count
  end
end
