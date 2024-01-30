# frozen_string_literal: true

require 'test_helper'

class QualysConfigTest < ActiveSupport::TestCase
  test 'that vm and wa import schedules are created with empty value when creating config' do
    # GIVEN no job scheduled
    setup_scheduler
    assert_equal(0, Resque::Scheduler.rufus_scheduler.jobs.size)
    # WHEN creating qualys config
    QualysConfig.create!(
      name: 'qualysConfig',
      login: 'something',
      password: 'password',
      url: 'someurl',
      vm_import_cron: '',
      wa_import_cron: ''
    )
    Resque::Scheduler.update_schedule
    # THEN no new job has been scheduled as empty cron values are not scheduled
    assert_equal(0, Resque::Scheduler.rufus_scheduler.jobs.size)
  end

  test 'that vm import and wa import are scheduled when creating qualys_config' do
    # GIVEN no job scheduled
    setup_scheduler
    assert_equal(0, Resque::Scheduler.rufus_scheduler.jobs.size)
    # and a qualys config with empty crons
    config = QualysConfig.create!(
      name: 'qualysConfig',
      login: 'something',
      password: 'password',
      url: 'someurl',
      vm_import_cron: '',
      wa_import_cron: ''
    )
    Resque::Scheduler.update_schedule
    assert_equal(0, Resque::Scheduler.rufus_scheduler.jobs.size)
    # WHEN updating qualys config
    config.update!(
      vm_import_cron: '0 0 * * *',
      wa_import_cron: '0 1 * * *'
    )
    Resque::Scheduler.update_schedule
    # THEN 2 new job has been scheduled
    assert_equal(2, Resque::Scheduler.rufus_scheduler.jobs.size)
  end

  test 'that schedules are removed when discarding a qualys config' do
    # GIVEN no job scheduled
    setup_scheduler
    assert_equal(0, Resque::Scheduler.rufus_scheduler.jobs.size)
    # and a qualys config with empty crons
    config = QualysConfig.create!(
      name: 'qualysConfig',
      login: 'something',
      password: 'password',
      url: 'someurl',
      vm_import_cron: '0 0 * * *',
      wa_import_cron: '0 1 * * *'
    )
    Resque::Scheduler.update_schedule
    assert_equal(2, Resque::Scheduler.rufus_scheduler.jobs.size)
    # WHEN updating qualys config
    config.discard!
    Resque::Scheduler.update_schedule
    # THEN all jobs have been unscheduled
    assert_equal(0, Resque::Scheduler.rufus_scheduler.jobs.size)
  end

  test 'that schedules are reset when undiscarding a qualys config' do
    # GIVEN no job scheduled
    setup_scheduler
    assert_equal(0, Resque::Scheduler.rufus_scheduler.jobs.size)
    # and a qualys config with empty crons
    config = QualysConfig.create!(
      name: 'qualysConfig',
      login: 'something',
      password: 'password',
      url: 'someurl',
      vm_import_cron: '0 0 * * *',
      wa_import_cron: '0 1 * * *'
    )
    Resque::Scheduler.update_schedule
    assert_equal(2, Resque::Scheduler.rufus_scheduler.jobs.size)
    # WHEN updating qualys config
    config.discard!
    Resque::Scheduler.update_schedule
    # THEN all jobs have been unscheduled
    assert_equal(0, Resque::Scheduler.rufus_scheduler.jobs.size)
    config.undiscard!
    Resque::Scheduler.update_schedule
    # THEN all jobs have been unscheduled
    assert_equal(2, Resque::Scheduler.rufus_scheduler.jobs.size)
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
