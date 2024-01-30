# frozen_string_literal: true

require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  test 'that fname permuts project id' do
    project = Project.new
    project.id = 'aa67c98c-d81f-5a9c-b0bc-26caa0051aea'
    assert_equal('ca9', project.fname('dir'), 'Directory obfuscation problem')
    assert_equal('98pq81s5nn67n0051nrn81s5n9po0op26pnn0051nrn', project.fname('file'),
      'File obfuscation problem')
  end

  test 'that report auto generation is scheduled when creating project w/ auto_generation' do
    # GIVEN no job scheduled
    setup_scheduler
    assert_equal(0, Resque::Scheduler.rufus_scheduler.jobs.size)
    # WHEN creating project w/ auto_generation
    Project.create!(
      name: 'new project',
      auto_generate: true,
      client: Client.first,
      teams: [Team.first],
      scan_regex: 'something',
      report_auto_generation_cron: '0 0 * * *'
    )
    Resque::Scheduler.update_schedule
    # THEN a new job has been scheduled
    assert_equal(1, Resque::Scheduler.rufus_scheduler.jobs.size)
  end

  test 'that report auto generation is scheduled when updating project w/ auto_generation' do
    # GIVEN no job scheduled
    setup_scheduler
    assert_equal(0, Resque::Scheduler.rufus_scheduler.jobs.size)
    # WHEN creating project w/out auto_generation
    project = Project.create!(
      name: 'new project',
      auto_generate: false,
      client: Client.first,
      teams: [Team.first]
    )
    Resque::Scheduler.update_schedule
    # THEN no new job has been scheduled
    assert_equal(0, Resque::Scheduler.rufus_scheduler.jobs.size)
    # WHEN updating project w/ auto_generate
    project.update(
      auto_generate: true,
      scan_regex: 'something',
      report_auto_generation_cron: '0 0 * * *'
    )
    # THEN 1 new job has been scheduled
    Resque::Scheduler.update_schedule
    # THEN no new job has been scheduled
    assert_equal(1, Resque::Scheduler.rufus_scheduler.jobs.size)
  end

  test 'that report auto generation schedule is removed when updating project w/out auto_gen' do
    # GIVEN no job scheduled
    setup_scheduler
    assert_equal(0, Resque::Scheduler.rufus_scheduler.jobs.size)
    # WHEN creating project w/ auto_generation
    project = Project.create!(
      name: 'new project',
      auto_generate: true,
      client: Client.first,
      teams: [Team.first],
      scan_regex: 'something',
      report_auto_generation_cron: '0 0 * * *'
    )
    Resque::Scheduler.update_schedule
    # THEN a new job has been scheduled
    assert_equal(1, Resque::Scheduler.rufus_scheduler.jobs.size)
    # WHEN updating project w/out auto_generate
    project.update!(auto_generate: false)
    # THEN scheduled job is removed
    Resque::Scheduler.update_schedule
    # THEN a new job has been scheduled
    assert_equal(0, Resque::Scheduler.rufus_scheduler.jobs.size)
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
