# frozen_string_literal: true

require 'test_helper'

class ReportTest < ActiveSupport::TestCase
  test 'that scoring is well regenerated' do
    report = scan_reports(:mapui)
    assert_equal(Report.levels.keys[1], report.level)
    assert_equal(120, report.scoring_vm)
    assert_equal(45, report.scoring_wa)
    new_scoring_system = 8
    new_scoring_applicative = 4
    report.regenerate_scoring
    report.reload
    assert_equal(Report.levels.keys[1], report.level)
    assert_equal(new_scoring_system, report.scoring_vm)
    assert_equal(new_scoring_applicative, report.scoring_wa)
  end

  test 'that report signatories list contains uniq elements' do
    # GIVEN a report
    # linked to a project linked to multiple teams with 2 users present in at least 2 teams
    user1 = UserService.add({ email: 'some@mail.com', full_name: 'name' }, [Group.staff], [])
    user2 = UserService.add({ email: 'some2@mail.com', full_name: 'name2' }, [Group.staff], [])
    user3 = UserService.add({ email: 'some3@mail.com', full_name: 'name3' }, [Group.staff], [])
    user4 = UserService.add({ email: 'some4@mail.com', full_name: 'name4' }, [Group.contact], [])
    team1 = Team.create(name: 'team1')
    team1.staffs << [user1, user2]
    team2 = Team.create(name: 'team2')
    team2.staffs << [user1, user2, user3]
    client1 = Client.first
    client1.contacts << [user4]
    project = Project.create!(name: 'project', client: Client.first, teams: [team1, team2])
    today = Time.zone.now
    report = Report.create!(project: project, staff: user2, title: "#{project} #{today}",
      edited_at: today, contacts: project.client.contacts.limit(5))

    # WHEN
    # listing potential report signatories
    # THEN
    # the user present in multiple teams only appears once
    assert_equal(1, report.potential_signatories(user2).count { |_label, id| id == user1.id })
  end

  test 'that report diffusion list does not include any deactivated user' do
    # GIVEN a report
    user1 = UserService.add({ email: 'some@mail.com', full_name: 'name' }, [Group.contact], [])
    user2 = UserService.add({ email: 'some2@mail.com', full_name: 'name2' }, [Group.contact], [])
    user3 = UserService.add({ email: 'some3@mail.com', full_name: 'name3' }, [Group.contact], [])
    user4 = UserService.add({ email: 'some4@mail.com', full_name: 'name4' }, [Group.staff], [])
    user5 = UserService.add({ email: 'some5@mail.com', full_name: 'name5' }, [Group.staff], [])
    team1 = Team.create(name: 'team1')
    team1.staffs << [user5]
    client1 = Client.create!(name: 'client1', internal_type: 'client')
    client1.contacts << [user1, user2, user3]
    project = Project.create!(name: 'project', client: client1, teams: [team1])
    today = Time.zone.now
    report = Report.create!(project: project, staff: user4, title: "#{project} #{today}",
      edited_at: today, contacts: client1.contacts)
    assert_equal 3, report.contacts.count
    # with at least one deactivated user
    user3.inactif!
    assert_not user3.actif?
    user2.discard!
    assert user2.discarded?
    # WHEN fetching diffusion list
    # THEN deactivated user is not present in result
    assert_equal 1, report.diffusion_list.count
    assert_equal [['name (some@mail.com)']], report.diffusion_list
  end

  test 'that a report with same edited_at date as a discarded one can be created' do
    # GIVEN
    # A project with 2 reports whose one discarded
    project = Project.first
    report = Report.first
    edited_at = report.edited_at
    project.reports = [report]
    report.discard!
    # WHEN
    # Trying to create a new report with same edited_at date as discarded one
    new_report = Report.create!(project: project, staff: User.staffs.first, title: "#{project} 1",
      edited_at: edited_at, contacts: project.client.contacts.limit(5))
    # THEN
    # Report is created
    assert_equal edited_at, new_report.edited_at
    # WHEN
    # Deleting this project
    new_report.discard!
    assert new_report.discarded?
    # And trying to create a new one with same edited_at date
    new_report2 = Report.create!(project: project, staff: User.staffs.first, title: "#{project} 1",
      edited_at: edited_at, contacts: project.client.contacts.limit(5))
    # THEN
    # Report is created
    assert_equal edited_at, new_report2.edited_at
  end
end
