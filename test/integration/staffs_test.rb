# frozen_string_literal: true

require 'test_helper'

class StaffsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include Rails.application.class.routes.url_helpers

  test 'authenticated staff cannot view authentication/login page' do
    sign_in users(:staffuser)
    get new_user_session_path
    assert_redirected_to root_path
  end

  test 'only authenticated staff super admin can access audit-logs page' do
    sign_in users(:staffuser)
    get audit_logs_path
    check_not_authorized
    sign_in users(:superadmin)
    get audit_logs_path
    assert_response :success
  end

  test 'unauthenticated cannot view audit-logs page' do
    get audit_logs_path
    check_not_authenticated
  end

  test 'unauthenticated cannot list staff' do
    get staffs_path
    check_not_authenticated
  end

  test 'unauthenticated cannot create staff members' do
    post staffs_path, params:
    {
      staff:
      {
        full_name: 'test',
        email: 'test@test.test'
      }
    }
    check_not_authenticated
  end

  test 'authenticated staff can list staffs' do
    sign_in users(:staffuser)
    get staffs_path
    assert_select 'main table.table' do
      User.staffs.page(1).each do |staff|
        assert_select 'td a .username', text: staff.full_name
      end
    end
  end

  test 'authenticated staff cyber_admin only can create staff members' do
    sign_in users(:cyberanalyst)
    new_name = 'test'
    post staffs_path, params:
    {
      staff:
      {
        full_name: new_name,
        email: 'test@test.test',
        language_id: Language.first.id,
        staff_team_ids: [Team.first.id],
        role_ids: ['', roles(:cyber_admin).id]
      }
    }
    assert_nil User.staffs.find_by(full_name: new_name)
    sign_in users(:staffuser)
    post staffs_path, params:
    {
      staff:
      {
        full_name: new_name,
        email: 'test@test.test',
        language_id: Language.first.id,
        staff_team_ids: [Team.first.id],
        role_ids: ['', roles(:cyber_admin).id]
      }
    }
    new_user = User.staffs.find_by(full_name: new_name)
    assert_not_nil new_user
    assert_redirected_to staff_path(new_user)
    get staff_path(new_user)
    assert_response 200
  end

  test 'staff creation without send_confirmation_notification does not send anything' do
    new_name = 'test'
    sign_in users(:staffuser)
    assert_enqueued_emails 0 do
      post staffs_path, params:
      {
        staff:
        {
          full_name: new_name,
          email: 'test@test.test',
          language_id: Language.first.id,
          send_confirmation_notification: '0',
          staff_team_ids: [Team.first.id],
          role_ids: [roles(:cyber_admin).id]
        }
      }
      assert_not_nil User.staffs.find_by(full_name: new_name)
    end
    new_name = 'someone'
    assert_enqueued_emails 1 do
      post staffs_path, params:
      {
        staff:
        {
          full_name: new_name,
          email: 'someone@test.test',
          language_id: Language.first.id,
          send_confirmation_notification: '1',
          staff_team_ids: [Team.first.id],
          role_ids: [roles(:cyber_admin).id]
        }
      }
      assert_not_nil User.staffs.find_by(full_name: new_name)
    end
  end

  test 'unauthenticated cannot view new staff form' do
    get new_staff_path
    check_not_authenticated
  end

  test 'unauthenticated cannot view edit staff form' do
    get edit_staff_path(User.staffs.first)
    check_not_authenticated
  end

  test 'unauthenticated cannot view staff infos' do
    get staff_path(User.staffs.first)
    check_not_authenticated
  end

  test 'unauthenticated cannot update staff' do
    put staff_path(User.staffs.first), params:
    {
      staff:
      {
        full_name: 'update',
        email: 'update@test.test',
        language_id: Language.first.id,
        staff_team_ids: [Team.first.id],
        role_ids: [roles(:contact_admin).id]
      }
    }
    check_not_authenticated
  end

  test 'unauthenticated cannot destroy staff' do
    delete staff_path(User.staffs.first)
    check_not_authenticated
  end

  test 'authenticated staff can view new staff form' do
    sign_in users(:staffuser)
    get new_staff_path
    assert_response :success
  end

  test 'authenticated staff can view edit staff form' do
    sign_in users(:staffuser)
    get edit_staff_path(User.staffs.first)
    assert_response :success
  end

  test 'authenticated staff can view staff infos' do
    sign_in users(:staffuser)
    get staff_path(User.staffs.first)
    assert_response :success
  end

  test 'authenticated cyber_admin can update their staff colleagues' do
    sign_in users(:staffuser)
    name = 'update'
    put staff_path(users(:staffuser2).id), params:
    {
      staff:
      {
        full_name: name,
        email: 'update@test.test',
        language_id: Language.first.id,
        staff_team_ids: [teams(:team_one).id],
        role_ids: ['', roles(:contact_admin).id]
      }
    }
    assert User.staffs.find_by(full_name: name).has_role?(:contact_admin)
  end

  test 'authenticated cyber_admin can self update only some fields' do
    sign_in users(:staffuser)
    name = 'update'
    put staff_path(users(:staffuser).id), params:
    {
      staff:
      {
        full_name: name,
        email: 'update@test.test',
        language_id: Language.first.id,
        staff_team_ids: [], # Teams are disabled
        role_ids: [roles(:contact_admin).id] # Highest priority role is disabled
      }
    }

    updated = User.staffs.find_by(full_name: name)

    assert updated.has_role?(:contact_admin)
    assert updated.has_role?(:cyber_admin)
  end

  test 'authenticated malicious staff cyber_admin can try to become super_admin' do
    sign_in users(:staffuser)
    name = 'update'
    put staff_path(users(:staffuser).id), params:
    {
      staff:
      {
        full_name: name,
        email: 'update@test.test',
        language_id: Language.first.id,
        staff_team_ids: [],
        role_ids: [roles(:super_admin).id] # Inject super_admin role id (=> hacker has found id)
      }
    }
    assert_not User.staffs.find_by(full_name: name).has_role?(:super_admin)
  end

  test 'authenticated malicious staff cyber_admin can try to make another super_admin' do
    sign_in users(:staffuser)
    name = 'update'
    put staff_path(users(:staffuser2).id), params:
    {
      staff:
      {
        full_name: name,
        email: 'update@test.test',
        language_id: Language.first.id,
        staff_team_ids: [],
        role_ids: [roles(:super_admin).id] # Inject super_admin role id (=> hacker has found id)
      }
    }
    assert_not User.staffs.find_by(full_name: name).has_role?(:super_admin)
  end

  test 'authenticated staff can destroy staff member if not self' do
    self_staff = users(:staffuser)
    sign_in users(:staffuser)
    delete staff_path(self_staff.id)
    assert_equal flash[:alert], I18n.t('actions.notices.no_rights')
    delete staff_path(User.staffs.where.not(id: self_staff.id).first)
    assert_equal flash[:notice], I18n.t('users.notices.deletion_success')
  end

  test 'authenticated staff cyber_admin can activate staff account' do
    sign_in users(:staffuser)
    staff = User.staffs.inactif.first
    assert_equal 'inactif', User.staffs.find(staff.id).state
    put activate_staff_path(staff), params: {}
    assert_equal 'actif', User.staffs.find(staff.id).state
  end

  test 'unauthenticated cannot activate staff account' do
    staff = User.staffs.inactif.first
    assert_equal 'inactif', User.staffs.find(staff.id).state
    put activate_staff_path(staff), params: {}
    assert_equal 'inactif', User.staffs.find(staff.id).state
    check_not_authenticated
  end

  test 'authenticated staff cyber_admin can resend instructions to reset staff password' do
    sign_in users(:staffuser)
    staff = User.staffs.actif.first
    assert User.staffs.find(staff.id).reset_password_sent_at.blank?
    post send_reset_password_staff_path(staff), params: {}
    assert User.staffs.find(staff.id).reset_password_sent_at.present?
    assert User.staffs.find(staff.id).reset_password_token.present?
  end

  test 'unauthenticated cannot resend instructions to reset staff password' do
    staff = User.staffs.actif.first
    assert User.staffs.find(staff.id).reset_password_sent_at.blank?
    post send_reset_password_staff_path(staff), params: {}
    assert User.staffs.find(staff.id).reset_password_sent_at.blank?
    assert User.staffs.find(staff.id).reset_password_token.blank?
    check_not_authenticated
  end

  test 'authenticated staff contact_admin can resend instructions to confirm staff account' do
    sign_in users(:staffuser)
    staff = User.staffs.actif.first
    staff.update(confirmed_at: nil)
    staff.send_confirmation_instructions
    first_token = User.staffs.find(staff.id).confirmation_token
    first_sent = User.staffs.find(staff.id).confirmation_sent_at
    put resend_confirmation_staff_path(staff), params: {}
    # Devise utilise le même token si présent (car valide seulement sur une durée)
    # la date d'envoi est générée en même temps que le token
    assert_equal User.staffs.find(staff.id).confirmation_token, first_token
    assert_equal User.staffs.find(staff.id).confirmation_sent_at, first_sent
  end

  test 'unauthenticated cannot resend instructions to confirm staff account' do
    staff = User.staffs.actif.first
    assert_not User.staffs.find(staff.id).pending_reconfirmation?
    put resend_confirmation_staff_path(staff), params: {}
    check_not_authenticated
    assert_not User.staffs.find(staff.id).pending_reconfirmation?
  end

  test 'authenticated staff contact_admin can deactivate staff account' do
    sign_in users(:staffuser)
    staff = User.staffs.actif.first
    assert_equal 'actif', User.staffs.find(staff.id).state
    put deactivate_staff_path(staff), params: {}
    assert_equal 'inactif', User.staffs.find(staff.id).state
  end

  test 'unauthenticated cannot deactivate staff account' do
    staff = User.staffs.actif.first
    assert_equal 'actif', User.staffs.find(staff.id).state
    put deactivate_staff_path(staff), params: {}
    assert_equal 'actif', User.staffs.find(staff.id).state
    check_not_authenticated
  end

  test 'authenticated staff cannot create new staff without full_name' do
    sign_in users(:staffuser)
    post staffs_path, params:
    {
      staff:
      {
        email: 'test@test.test'
      }
    }
    assert_response(200)
  end

  test 'authenticated staff cannot create new staff without email' do
    sign_in users(:staffuser)
    post staffs_path, params:
    {
      staff:
      {
        full_name: 'test'
      }
    }
    assert_response(200)
  end

  test 'authenticated staff cannot update staff member without full_name' do
    sign_in users(:staffuser)
    put staff_path(User.staffs.first), params:
    {
      staff:
      {
        full_name: nil,
        email: 'test@test.test'
      }
    }
    assert_response(200)
  end

  test 'authenticated staff cannot update staff member without email' do
    sign_in users(:staffuser)
    put staff_path(User.staffs.first), params:
    {
      staff:
      {
        full_name: 'test',
        email: nil
      }
    }
    assert_response(200)
  end

  test 'authenticated cyber_admin can delete staff roles' do
    sign_in users(:staffuser)
    name = 'update'
    put staff_path(users(:staffuser2).id), params:
    {
      staff:
      {
        full_name: name,
        email: 'update@test.test',
        language_id: Language.first.id,
        staff_team_ids: [teams(:team_one).id],
        role_ids: []
      }
    }
    assert User.staffs.find_by(full_name: name).roles.empty?
  end

  test 'authenticated cyber_admin cannot delete super_admin role' do
    sign_in users(:staffuser)
    name = 'update'
    put staff_path(users(:superadmin).id), params:
    {
      staff:
      {
        full_name: name,
        email: 'update@test.test',
        language_id: Language.first.id,
        staff_team_ids: [teams(:team_one).id],
        role_ids: []
      }
    }
    assert User.staffs.find_by(full_name: name).has_role?(:super_admin)
  end

  test 'authenticated cyber_admin can delete super_admin role if super_admin himself' do
    s = users(:staffuser)
    s.add_role(:super_admin)
    sign_in s
    name = 'update'
    put staff_path(users(:superadmin).id), params:
    {
      staff:
      {
        full_name: name,
        email: 'update@test.test',
        language_id: Language.first.id,
        staff_team_ids: [teams(:team_one).id],
        role_ids: []
      }
    }
    assert User.staffs.find_by(full_name: name).roles.empty?
  end

  test 'staff is redirected to set his password after confirmation' do
    staff = User.staffs.actif.first
    staff.send_confirmation_instructions
    get user_confirmation_url(confirmation_token: staff.confirmation_token)
    assert_response :redirect
    assert_match(%r{.*/users/password/edit\?reset_password_token=.*}, @response.redirect_url)
  end

  test 'confirmations#new/create are not authorized' do
    get new_user_confirmation_path
    check_not_authorized
    post user_confirmation_path
    check_not_authorized
  end

  test 'unlocks#new/create are not authorized' do
    get new_user_unlock_path
    check_not_authorized
    post user_unlock_path
    check_not_authorized
  end

  # 2FA
  test 'unauthenticated cannot force_mfa on a staff' do
    put force_mfa_user_path(User.staffs.first)
    check_not_authenticated
  end

  test 'authenticated super_admin only can force_mfa on a staff only if not already forced' do
    staff = User.staffs.first
    assert_not(staff.otp_mandatory?)
    sign_in users(:staffuser)
    put force_mfa_user_path(staff)
    check_not_authorized # Not superadmin
    sign_in users(:superadmin)
    put force_mfa_user_path(staff)
    assert_redirected_to root_path # back in history
    assert(staff.reload.otp_mandatory?)
  end

  test 'unauthenticated cannot unforce_mfa on a staff' do
    put unforce_mfa_user_path(User.staffs.first)
    check_not_authenticated
  end

  test 'authenticated super_admin only can unforce_mfa on a staff only if already forced' do
    staff = User.staffs.first
    assert_not(staff.otp_mandatory?)
    sign_in users(:staffuser)
    put unforce_mfa_user_path(staff)
    check_not_authorized # Not superadmin
    sign_in users(:superadmin)
    put unforce_mfa_user_path(staff)
    check_not_authorized
    put force_mfa_user_path(staff)
    assert_redirected_to root_path # back in history
    assert(staff.reload.otp_mandatory?)
    put unforce_mfa_user_path(staff)
    assert_redirected_to root_path # back in history = last get
    assert_not(staff.reload.otp_mandatory?)
  end

  test 'unauthenticated cannot force direct otp' do
    put force_direct_otp_staff_path(User.staffs.first)
    check_not_authenticated
  end

  test 'authenticated admin can force direct otp only on staff not self not discarded with otp
    activated and totp enabled' do
    user = users(:superadmin) # cyber_admin not discarded
    sign_in user
    # self
    put force_direct_otp_staff_path(user)
    check_not_authorized
    # Not self
    target = users(:staffuser2)
    put force_direct_otp_staff_path(target)
    check_not_authorized
    # force mfa for target
    put force_mfa_user_path(target)
    target = target.reload
    assert(target.otp_activated?)
    # Totp not enabled
    put force_direct_otp_staff_path(target)
    check_not_authorized
    # Disable mfa for target for ease of test
    put unforce_mfa_user_path(target)
    target = target.reload
    assert_not(target.otp_activated?)
    # Enable totp for target
    delete logout_path
    sign_in target
    assert_not(target.otp_activated?)
    assert_not(target.totp_enabled?)
    post activate_otp_path
    post setup_otp_authenticator_path
    target = target.reload
    token = target.totp_configuration_token
    assert_redirected_to configure_otp_authenticator_path(token: token)
    target = target.reload
    assert(target.totp_enabled?)
    get configure_otp_authenticator_path(token: token)
    assert_response :success
    delete logout_path
    sign_in user
    put force_direct_otp_staff_path(target)
    assert_redirected_to root_path # back in history
    target = target.reload
    assert_not(target.totp_enabled?)
  end

  test 'unauthenticated cannot force unlock' do
    put force_unlock_staff_path(User.staffs.first)
    check_not_authenticated
  end

  test 'authenticated staff super admin only can force unlock a user if locked' do
    target = users(:c_one)
    target.lock_access!
    assert(target.access_locked?)
    sign_in users(:staffuser)
    put force_unlock_contact_path(target)
    check_not_authorized
    sign_in users(:superadmin)
    put force_unlock_contact_path(target)
    assert_redirected_to root_path # back in history
    assert_not(target.reload.access_locked?)
  end

  test 'unauthenticated cannot send unlock' do
    post send_unlock_staff_path(User.staffs.first)
    check_not_authenticated
  end

  test 'authenticated staff admin can send unlock instructions to a user if locked' do
    user = users(:staffuser)
    sign_in user
    target = users(:c_one)
    target.lock_access!
    assert(target.access_locked?)
    post send_unlock_contact_path(target)
    assert_redirected_to root_path # back in history
    assert(target.reload.unlock_token.present?)
  end

  test 'unauthenticated cannot see staff public_key' do
    get public_key_user_path(User.staffs.first), xhr: true
    check_unauthorized # AJAX
  end

  test 'authenticated can see user public_key if present' do
    user = users(:staffuser)
    sign_in user
    target = users(:c_one)
    get public_key_user_path(target), xhr: true
    assert_response :success
    assert_equal(response.body, '"error"') # user has no public_key
    delete logout_path
    sign_in target
    GPGME::Key.import(File.open(Gpg::TESTS_PUB_KEY))
    File.open(Gpg::TESTS_PUB_KEY) do |f|
      public_key = f.read
      put edit_profile_public_key_path, params: {
        user:
          {
            public_key: public_key
          }
      }
    end
    target = target.reload
    assert(target.public_key.present?)
    delete logout_path
    sign_in user
    get public_key_user_path(target)
    assert_response :success
    assert_not_equal(response.body, '"error"') # user has a public_key
  end
end
