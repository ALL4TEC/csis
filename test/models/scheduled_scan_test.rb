# frozen_string_literal: true

require 'test_helper'

class ScheduledScanTest < ActiveSupport::TestCase
  test 'that scheduledScan cron is scheduled when creating scheduledScan' do
    # GIVEN no job scheduled
    setup_scheduler
    assert_equal(0, Resque::Scheduler.rufus_scheduler.jobs.size)
    # WHEN creating scheduled scan
    ScheduledScan.create!(
      scan_configuration_id: ScanConfiguration.first.id,
      project: Project.first,
      scheduled_scan_cron: '0 0 * * *'
    )
    Resque::Scheduler.update_schedule
    # THEN no new job has been scheduled as empty cron values are not scheduled
    assert_equal(1, Resque::Scheduler.rufus_scheduler.jobs.size)
  end

  test 'that scheduledScan cron is scheduled when updating scheduledScan' do
    # GIVEN no job scheduled
    setup_scheduler
    assert_equal(0, Resque::Scheduler.rufus_scheduler.jobs.size)
    # WHEN creating scheduled scan
    scheduled_scan = ScheduledScan.create!(
      scan_configuration_id: ScanConfiguration.first.id,
      project: Project.first,
      scheduled_scan_cron: ''
    )
    Resque::Scheduler.update_schedule
    # THEN no new job has been scheduled as empty cron values are not scheduled
    assert_equal(0, Resque::Scheduler.rufus_scheduler.jobs.size)
    scheduled_scan.update!(
      scheduled_scan_cron: '0 0 * * *'
    )
    Resque::Scheduler.update_schedule
    # THEN no new job has been scheduled as empty cron values are not scheduled
    assert_equal(1, Resque::Scheduler.rufus_scheduler.jobs.size)
  end

  test 'that schedules are removed when discarding a scheduled scan' do
    # GIVEN no job scheduled
    setup_scheduler
    assert_equal(0, Resque::Scheduler.rufus_scheduler.jobs.size)
    # and a qualys config with empty crons
    scheduled_scan = ScheduledScan.create!(
      scan_configuration_id: ScanConfiguration.first.id,
      project: Project.first,
      scheduled_scan_cron: '0 0 * * *'
    )
    Resque::Scheduler.update_schedule
    assert_equal(1, Resque::Scheduler.rufus_scheduler.jobs.size)
    # WHEN updating qualys config
    scheduled_scan.discard!
    Resque::Scheduler.update_schedule
    # THEN all jobs have been unscheduled
    assert_equal(0, Resque::Scheduler.rufus_scheduler.jobs.size)
  end

  test 'that schedules are reset when undiscarding a scheduled scan' do
    # GIVEN no job scheduled
    setup_scheduler
    assert_equal(0, Resque::Scheduler.rufus_scheduler.jobs.size)
    # and a qualys config with empty crons
    scheduled_scan = ScheduledScan.create!(
      scan_configuration_id: ScanConfiguration.first.id,
      project: Project.first,
      scheduled_scan_cron: '0 0 * * *'
    )
    Resque::Scheduler.update_schedule
    assert_equal(1, Resque::Scheduler.rufus_scheduler.jobs.size)
    # WHEN updating qualys config
    scheduled_scan.discard!
    Resque::Scheduler.update_schedule
    # THEN all jobs have been unscheduled
    assert_equal(0, Resque::Scheduler.rufus_scheduler.jobs.size)
    scheduled_scan.undiscard!
    Resque::Scheduler.update_schedule
    # THEN all jobs have been unscheduled
    assert_equal(1, Resque::Scheduler.rufus_scheduler.jobs.size)
  end

  private

  def setup_scheduler
    Resque::Scheduler.clear_schedule!
    Resque.schedule.each_key do |name|
      Resque.remove_schedule(name)
    end
    Resque::Scheduler.configure do |c|
      c.dynamic = true
      c.quiet = true
      c.env = nil
      c.app_name = nil
    end
  end
end
