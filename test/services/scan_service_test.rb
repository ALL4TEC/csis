# frozen_string_literal: true

require 'test_helper'

class ScanServiceTest < ActiveJob::TestCase
  test 'User linked to teams linked to a cyberwatchconfig w/out scan
    and linked to a qualysconfig with scans can see all related scans' do
    # GIVEN a user member of staff group linked to a cyberwatchconfig w/out any scan(cbw_two)
    # And a qualysconfig (qc_one) with scans (vm and wa)
    # WHEN asking for visible scans
    # THEN it returns all available scans: thus those linked to qualys

    staff = users(:staffuser)
    # Remove cbw_one as it contains scans
    account_teams(:account_teamone_cbw_one).destroy!
    assert_equal 1, staff.cyberwatch_configs.count
    assert staff.cbw_scans.count.zero?
    assert_equal 1, staff.qualys_configs.count
    qualysconfig = staff.qualys_configs.first
    assert_equal 4, qualysconfig.vm_scans.count
    assert_equal 4, ScanService.visible_accounts_scans_ids(staff, :vm).count
  end

  test 'User linked to teams linked to a cyberwatchconfig with scans
    and linked to a qualysconfig with scans can see all related scans' do
    # GIVEN a user linked to a cyberwatchconfig with some scans
    # And a qualysconfig with scans
    # WHEN asking for visible scans
    # THEN it returns all available scans: thus those linked to qualys
    # + those linked to cyberwatchconfig
    staff = users(:staffuser)
    assert_equal 2, staff.cyberwatch_configs.count
    assert_equal 2, staff.cbw_scans.count
    assert_equal 1, staff.qualys_configs.count
    qualysconfig = staff.qualys_configs.first
    assert_equal 4, qualysconfig.vm_scans.count
    assert_equal 6, ScanService.visible_accounts_scans_ids(staff, :vm).count
  end

  test 'User linked to teams not linked to any scanner account can see all related scans' do
    # GIVEN a user linked to no scanner config
    # WHEN asking for visible scans
    # THEN it returns no scan

    staff = users(:staffuser)
    staff.update!(staff_teams: [])
    assert staff.team_accounts.count.zero?
    assert_equal 0, ScanService.visible_accounts_scans_ids(staff, :vm).count
  end
end
