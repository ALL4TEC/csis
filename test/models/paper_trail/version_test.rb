# frozen_string_literal: true

require 'test_helper'

class VersionTest < ActiveSupport::TestCase
  test 'job is scheduled' do
    # GIVEN no job scheduled
    Resque::Scheduler.clear_schedule!
    Resque.schedule.each_key do |name|
      Resque.remove_schedule(name)
    end
    assert_equal(0, Resque::Scheduler.rufus_scheduler.jobs.size)
    # WHEN scheduling version maintenance
    PaperTrail::Version.schedule_maintenance
    Resque::Scheduler.load_schedule!
    # THEN a new job has been scheduled
    assert_equal(1, Resque::Scheduler.rufus_scheduler.jobs.size)
  end
end
