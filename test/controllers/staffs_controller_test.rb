# frozen_string_literal: true

require 'test_helper'

class StaffsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'unauthenticated staff should get login' do
    get new_user_session_url
    assert_response :success
  end

  test 'authenticated staff should get redirected to dashboard' do
    sign_in users(:staffuser)
    get new_user_session_url
    assert_redirected_to root_path
  end

  test 'unauthenticated cannot force activate staff' do
    put activate_staff_path(User.staffs.inactif.first)
    check_not_authenticated
  end

  test 'authenticated cyberanalyst cannot force activate staff' do
    staff = User.staffs.inactif.first
    sign_in users(:cyberanalyst)
    put activate_staff_path(staff)
    check_not_authorized
  end

  test 'authenticated cyberadmin can force activate staff' do
    staff = User.staffs.inactif.first
    sign_in users(:cyberadmin)
    put activate_staff_path(staff)
    assert_equal I18n.t('users.notices.activated'), flash[:notice]
    assert User.staffs.find(staff.id).actif?
  end

  test 'authenticated superadmin can force activate staff' do
    staff = User.staffs.inactif.first
    sign_in users(:superadmin)
    put activate_staff_path(staff)
    assert_equal I18n.t('users.notices.activated'), flash[:notice]
    assert User.staffs.find(staff.id).actif?
  end

  test 'authenticated super_admin can update staff password without old password' do
    user = users(:staffuser)
    sign_in users(:superadmin)
    new_pass = 'NewLongP@ssW0rd!'
    put force_reset_password_staff_path(user), params:
      {
        user:
          {
            id: user.id,
            password: new_pass,
            password_confirmation: new_pass
          }
      }
    assert User.staffs.find(user.id).valid_password?(new_pass)
  end

  # Force update email
  test 'authenticated super_admin can update contact email without having to confirm' do
    con = users(:staffuser)
    sign_in users(:superadmin)
    new_email = 'new.email@somedomain.eu'
    put force_update_email_staff_path(con), params:
      {
        user:
          {
            id: con.id,
            email: new_email
          }
      }
    staff = User.staffs.find(con.id)
    assert_equal new_email, staff.email
    assert staff.confirmed?
  end

  # Force confirm email
  test 'authenticated super_admin can force contact email confirmation' do
    con = User.staffs.find(users(:staffuser).id)
    con.update(confirmed_at: nil)
    assert_not con.confirmed?
    sign_in users(:superadmin)
    put force_confirm_staff_path(con)
    assert con.reload.confirmed?
  end

  # Force deactivate otp
  test 'authenticated super_admin can force contact otp deactivation' do
    con = User.staffs.find(users(:staffuser).id)
    con.activate_otp
    assert con.otp_activated?
    sign_in users(:superadmin)
    put force_deactivate_otp_staff_path(con)
    assert_not con.reload.otp_activated?
  end

  # Force unlock otp
  test 'authenticated super_admin can force contact otp unlock' do
    con = User.staffs.find(users(:staffuser).id)
    con.update(second_factor_attempts_count: 3)
    assert con.max_login_attempts?
    sign_in users(:superadmin)
    put force_unlock_otp_staff_path(con)
    assert_not con.reload.max_login_attempts?
  end
end
