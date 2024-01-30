# frozen_string_literal: true

require 'test_helper'

class GroupsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'unauthenticated cannot manage groups' do
    get groups_path
    check_not_authenticated
  end

  test 'authenticated super_admin only can manage groups' do
    sign_in users(:staffuser)
    get groups_path
    check_not_authorized
    sign_in users(:superadmin)
    get groups_path
    assert_response :success
  end

  test 'authenticated super_admin only can add user to group' do
    group = groups(:staff)
    user = users(:c_one)
    assert_not(user.in?(group.users))
    sign_in users(:staffuser)
    post add_user_to_group_path(group, user)
    check_unscoped # Due to scope resolution before authorization
    sign_in users(:superadmin)
    post add_user_to_group_path(group, user)
    assert_redirected_to root_path # back in history
    assert(user.in?(group.users))
  end

  test 'authenticated super_admin only can remove user from group only if user not in any team
    and still present in another group' do
    group = groups(:staff)
    user = users(:staffuser)
    assert(user.in?(group.users))
    sign_in users(:staffuser)
    delete remove_user_from_group_path(group, user)
    check_unscoped # Due to scope resolution before authorization
    sign_in users(:superadmin)
    delete remove_user_from_group_path(group, user)
    check_not_authorized # Due to one team of staff group attached to user
    assert(user.in?(group.users))
    # Removing staffuser from team
    put staff_path(user), params: {
      staff: {
        staff_team_ids: []
      }
    }
    assert_redirected_to staff_path(user)
    assert(User.find(user.id).staff_teams.blank?)
    delete remove_user_from_group_path(group, user)
    check_not_authorized # Due to no other current group
    post add_user_to_group_path(Group.contact, user)
    assert(user.in?(Group.contact.users))
    delete remove_user_from_group_path(group, user)
    assert_redirected_to root_path # back in history
    assert_not(user.in?(group.users))
  end

  test 'unauthenticated cannot force_mfa on a group' do
    put force_mfa_group_path(Group.first)
    check_not_authenticated
  end

  test 'authenticated super_admin only can force_mfa on a group only if not already forced' do
    group = Group.first
    assert_not(group.otp_mandatory?)
    sign_in users(:staffuser)
    put force_mfa_group_path(group)
    check_unscoped # Must get group before authorization
    sign_in users(:superadmin)
    put force_mfa_group_path(group)
    assert_redirected_to root_path # back in history
    assert(group.reload.otp_mandatory?)
  end

  test 'unauthenticated cannot unforce_mfa on a group' do
    put unforce_mfa_group_path(Group.first)
    check_not_authenticated
  end

  test 'authenticated super_admin only can unforce_mfa on a group only if already forced' do
    group = Group.first
    assert_not(group.otp_mandatory?)
    sign_in users(:staffuser)
    put unforce_mfa_group_path(group)
    check_unscoped # Must get group before authorization
    sign_in users(:superadmin)
    put unforce_mfa_group_path(group)
    check_not_authorized
    put force_mfa_group_path(group)
    assert_redirected_to root_path # back in history
    assert(group.reload.otp_mandatory?)
    put unforce_mfa_group_path(group)
    assert_redirected_to root_path # back in history = last get
    assert_not(group.reload.otp_mandatory?)
  end
end
