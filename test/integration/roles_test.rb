# frozen_string_literal: true

require 'test_helper'

class RolesTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'unauthenticated cannot force_mfa on a role' do
    put force_mfa_role_path(Role.first)
    check_not_authenticated
  end

  test 'authenticated super_admin only can force_mfa on a role only if not already forced' do
    role = Role.first
    assert_not(role.otp_mandatory?)
    sign_in users(:staffuser)
    put force_mfa_role_path(role)
    check_unscoped # Must get role before authorization
    sign_in users(:superadmin)
    put force_mfa_role_path(role)
    assert_redirected_to root_path # back in history
    assert(role.reload.otp_mandatory?)
  end

  test 'unauthenticated cannot unforce_mfa on a role' do
    put unforce_mfa_role_path(Role.first)
    check_not_authenticated
  end

  test 'authenticated super_admin only can unforce_mfa on a role only if already forced' do
    role = Role.first
    assert_not(role.otp_mandatory?)
    sign_in users(:staffuser)
    put unforce_mfa_role_path(role)
    check_unscoped # Must get role before authorization
    sign_in users(:superadmin)
    put unforce_mfa_role_path(role)
    check_not_authorized
    put force_mfa_role_path(role)
    assert_redirected_to root_path # back in history
    assert(role.reload.otp_mandatory?)
    put unforce_mfa_role_path(role)
    assert_redirected_to root_path # back in history = last get
    assert_not(role.reload.otp_mandatory?)
  end
end
