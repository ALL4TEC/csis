# frozen_string_literal: true

require 'test_helper'

class TeamsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'unauthenticated cannot list teams' do
    get teams_path
    check_not_authenticated
  end

  test 'unauthenticated cannot create teams' do
    post teams_path, params:
    {
      team:
      {
        name: 'test'
      }
    }
    check_not_authenticated
  end

  test 'authenticated staff can list teams' do
    sign_in users(:staffuser)
    get teams_path
    assert_select 'main table.table' do
      Team.page(1).each do |team|
        assert_select 'td .groupname', text: team.name
      end
    end
  end

  test 'authenticated staff can create teams' do
    sign_in users(:staffuser)
    post teams_path, params:
    {
      team:
      {
        name: 'test'
      }
    }
    assert_not_nil Team.find_by(name: 'test')
  end

  test 'unauthenticated cannot view new team form' do
    get new_team_path
    check_not_authenticated
  end

  test 'unauthenticated cannot view edit team form' do
    get edit_team_path(Team.first)
    check_not_authenticated
  end

  test 'unauthenticated cannot view team infos' do
    get team_path(Team.first)
    check_not_authenticated
  end

  test 'unauthenticated cannot update teams' do
    put team_path(Team.first), params:
    {
      team:
      {
        name: 'update'
      }
    }
    check_not_authenticated
  end

  test 'unauthenticated cannot destroy team' do
    delete team_path(Team.first)
    check_not_authenticated
  end

  test 'authenticated staff can view new team form' do
    sign_in users(:staffuser)
    get new_team_path
    assert_response :success
  end

  test 'authenticated staff can view edit team form' do
    sign_in users(:staffuser)
    get edit_team_path(Team.first)
    assert_response :success
  end

  test 'authenticated staff can view team infos' do
    sign_in users(:staffuser)
    get team_path(Team.first)
    assert_response :success
  end

  test 'authenticated staff can update teams' do
    sign_in users(:staffuser)
    put team_path(Team.first), params:
    {
      team:
      {
        name: 'update'
      }
    }
    assert_not_nil Team.find_by(name: 'update')
  end

  test 'authenticated staff can destroy team' do
    sign_in users(:staffuser)
    delete team_path(Team.first)
    assert_equal flash[:notice], I18n.t('teams.notices.deletion_success')
  end

  test 'authenticated staff cannot create new team without name' do
    sign_in users(:staffuser)
    post teams_path, params:
    {
      team:
      {
        name: nil
      }
    }
    assert_response(200)
  end

  test 'authenticated staff cannot update team without name' do
    sign_in users(:staffuser)
    put team_path(Team.first), params:
    {
      team:
      {
        name: nil
      }
    }
    assert_response(200)
  end

  # 2FA
  test 'unauthenticated cannot force_mfa on a team' do
    put force_mfa_team_path(Team.first)
    check_not_authenticated
  end

  test 'authenticated super_admin only can force_mfa on a team only if not already forced' do
    team = Team.first
    assert_not(team.otp_mandatory?)
    sign_in users(:staffuser)
    put force_mfa_team_path(team)
    check_not_authorized # Not super_admin
    sign_in users(:superadmin)
    put force_mfa_team_path(team)
    assert_redirected_to root_path # back in history
    assert(team.reload.otp_mandatory?)
  end

  test 'unauthenticated cannot unforce_mfa on a team' do
    put unforce_mfa_team_path(Team.first)
    check_not_authenticated
  end

  test 'authenticated super_admin only can unforce_mfa on a team only if already forced' do
    team = Team.first
    assert_not(team.otp_mandatory?)
    sign_in users(:staffuser)
    put unforce_mfa_team_path(team)
    check_not_authorized # Not super_admin
    sign_in users(:superadmin)
    put unforce_mfa_team_path(team)
    check_not_authorized
    put force_mfa_team_path(team)
    assert_redirected_to root_path # back in history
    assert(team.reload.otp_mandatory?)
    put unforce_mfa_team_path(team)
    assert_redirected_to root_path # back in history = last get
    assert_not(team.reload.otp_mandatory?)
  end
end
