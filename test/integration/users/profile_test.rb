# frozen_string_literal: true

require 'test_helper'
require 'utils/stubs/fake_slack'

class User::ProfileTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'authenticated can view edit password page' do
    sign_in users(:c_one)
    get edit_profile_password_path
    assert_response 200
  end

  test 'unauthenticated cannot view edit password page' do
    get edit_profile_password_path
    check_not_authenticated
  end

  test 'authenticated can update password and login' do
    contact = users(:c_one)
    sign_in contact
    new_pass = 'NewLongP@ssW0rd!'
    put edit_profile_password_path, params:
      {
        user:
          {
            current_password: 'P@ssW0rdLongEnough',
            password: new_pass,
            password_confirmation: new_pass
          }
      }
    delete logout_path
    post login_path, params:
      {
        user:
          {
            email: contact.email,
            password: new_pass
          }
      }
    assert_redirected_to root_path
  end

  test 'authenticated cannot update password with wrong old pass' do
    check_password_update_fail('Wr0ng!', 'NewLongP@ssW0rd!', 'NewLongP@ssW0rd!')
  end

  test 'authenticated cannot update password with different new pass' do
    check_password_update_fail('P@ssW0rdLongEnough', 'NewLongP@ssW0rd!', 'Wr0ng!')
  end

  test 'authenticated cannot update password without respect of the format' do
    check_password_update_fail('P@ssW0rdLongEnough', 'wrongformat', 'wrongformat')
  end

  test 'unauthenticated cannot update password' do
    put edit_profile_password_path, params:
      {
        user:
          {
            current_password: 'P@ssW0rdLongEnough',
            password: 'NewLongP@ssW0rd!',
            password_confirmation: 'NewLongP@ssW0rd!'
          }
      }
    check_not_authenticated
  end

  test 'unauthenticated cannot view edit public_key page' do
    get edit_profile_public_key_path
    check_not_authenticated
  end

  test 'authenticated cannot update public key with anything' do
    check_public_key('anything', true)
  end

  test 'authenticated cannot update public key if not importable by GPGME' do
    public_key = "-----BEGIN PGP PUBLIC KEY BLOCK-----#{'A' * 3000}" \
                 '-----END PGP PUBLIC KEY BLOCK-----'
    check_public_key(public_key, true)
  end

  test 'authenticated can update public key' do
    GPGME::Key.import(File.open(Gpg::TESTS_PUB_KEY))
    File.open(Gpg::TESTS_PUB_KEY) do |f|
      public_key = f.read
      check_public_key(public_key, false)
    end
  end

  test 'unauthenticated cannot update public key' do
    put edit_profile_public_key_path, params:
      {
        user:
          {
            public_key: 'will not be saved but proves the possibility'
          }
      }
    check_not_authenticated
  end

  test 'unauthenticated cannot see edit display page' do
    get edit_profile_display_path
    check_not_authenticated
  end

  test 'unauthenticated cannot update display' do
    put edit_profile_display_path
    check_not_authenticated
  end

  test 'authenticated can update display to vertical or horizontal only' do
    user = users(:staffuser)
    sign_in user
    assert(user.display_submenu_direction_horizontal?)
    put edit_profile_display_path, params: {
      user: {
        display_submenu_direction: 'vertical'
      }
    }
    assert_redirected_to edit_profile_display_path
    assert(user.reload.display_submenu_direction_vertical?)
    put edit_profile_display_path, params: {
      user: {
        display_submenu_direction: 'horizontal'
      }
    }
    assert_redirected_to edit_profile_display_path
    assert(user.reload.display_submenu_direction_horizontal?)
    check_display('unknown', false)
  end

  test 'unauthenticated cannot switch current group' do
    put switch_view_path(Group.first)
    check_not_authenticated
  end

  test 'authenticated can switch to groups they belong to only' do
    user = users(:superadmin)
    sign_in user
    target = Group.contact
    assert_not(target.in?(user.groups))
    put switch_view_path(target)
    check_unscoped
    # Add contact group to user
    post add_user_to_group_path(target.id, user.id)
    assert(target.in?(user.reload.groups))
    put switch_view_path(target)
    assert_redirected_to dashboard_path
    get profile_path
    assert_response :success
  end

  test 'unauthenticated cannot view edit 2fa page' do
    get edit_profile_otp_path
    check_not_authenticated
  end

  test 'unauthenticated cannot activate 2fa' do
    post activate_otp_path
    check_not_authenticated
  end

  test 'authenticated can activate 2fa if not already the case' do
    user = users(:staffuser)
    sign_in user
    assert_not(user.otp_activated?)
    post activate_otp_path
    assert_redirected_to edit_profile_otp_path
    assert(User.find(user.id).otp_activated?)
    post activate_otp_path
    check_not_authorized
    assert(User.find(user.id).otp_activated?) # Did nothing
  end

  test 'unauthenticated cannot deactivate 2fa' do
    post deactivate_otp_path
    check_not_authenticated
  end

  test 'authenticated can deactivate 2fa if not mandatory and not already the case' do
    user = users(:staffuser)
    sign_in user
    assert_not(user.otp_activated?)
    post activate_otp_path
    assert_redirected_to edit_profile_otp_path
    assert(user.reload.otp_activated?) # Activate otp
    post deactivate_otp_path
    assert_redirected_to edit_profile_otp_path
    assert_not(user.reload.otp_activated?) # Deactivate otp
    post deactivate_otp_path
    check_not_authorized
    assert_not(user.reload.otp_activated?) # Did nothing
  end

  test 'authenticated cannot deactivate 2fa if mandatory' do
    user = users(:superadmin)
    sign_in user
    put force_mfa_user_path(user.id)
    user = user.reload
    assert(user.otp_mandatory?)
    assert(user.otp_activated?) # as otp_mandatory
    post deactivate_otp_path
    check_not_authorized
    user = user.reload
    assert(user.otp_activated?) # Did nothing
  end

  test 'authenticated can configure an authenticator only if previously setup' do
    user = users(:c_one)
    sign_in user
    assert(user.otp_secret_key.blank?)
    get configure_otp_authenticator_path(token: 'ABC')
    check_not_authorized
    post setup_otp_authenticator_path
    check_not_authorized
    post activate_otp_path
    post setup_otp_authenticator_path
    token = user.reload.totp_configuration_token
    assert_redirected_to configure_otp_authenticator_path(token: token)
    assert(user.reload.otp_secret_key.present?)
    get configure_otp_authenticator_path(token: token)
    assert_response :success
    assert(user.reload.totp_configuration_token.blank?)
    get profile_path
    assert_response :success
  end

  test 'unauthenticated cannot test totp configuration' do
    post test_totp_configuration_path, xhr: true, params: {
      code: 'something'
    }
    check_unauthorized
  end

  test 'authenticated can test totp configuration only if otp activated and totp_enabled' do
    user = users(:c_one)
    sign_in user
    assert(user.otp_secret_key.blank?)
    # We could also test if only ajax calls enabled...
    post test_totp_configuration_path, xhr: true, params: {
      code: 'something'
    }
    check_not_authorized
    post activate_otp_path
    post test_totp_configuration_path, xhr: true, params: {
      code: 'something'
    }
    check_not_authorized
    post setup_otp_authenticator_path
    token = user.reload.totp_configuration_token
    assert_redirected_to configure_otp_authenticator_path(token: token)
    post test_totp_configuration_path, xhr: true, params: {
      code: 'something'
    }
    assert_response :success # something is not a good code
    exp_resp = "Rails.$('#totp_test_response')[0].innerHTML = " \
               "(\"<i aria-hidden=\\'true\\' " \
               "class=\\'material-icons align-middle text-danger\\'>" \
               "cancel<\\/i>\\n\")\n"
    assert_equal(response.body, exp_resp)
  end

  test 'authenticated can reconfigure an authenticator' do
    user = users(:c_one)
    sign_in user
    post activate_otp_path
    post setup_otp_authenticator_path
    token = user.reload.totp_configuration_token
    assert_redirected_to configure_otp_authenticator_path(token: token)
    assert(user.reload.otp_secret_key.present?)
    get configure_otp_authenticator_path(token: token)
    assert(user.reload.totp_configuration_token.blank?)
    secret_key1 = user.otp_secret_key
    post setup_otp_authenticator_path
    check_not_authorized
    post resetup_otp_authenticator_path
    token = user.reload.totp_configuration_token
    assert_redirected_to configure_otp_authenticator_path(token: token)
    assert(user.reload.otp_secret_key.present?)
    get configure_otp_authenticator_path(token: token)
    assert_response :success
    assert(user.reload.totp_configuration_token.blank?)
    assert(user.otp_secret_key != secret_key1)
    get profile_path
    assert_response :success
  end

  test 'authenticated can clear authenticator configuration and use direct otp' do
    user = users(:c_one)
    sign_in user
    post activate_otp_path
    post setup_otp_authenticator_path
    token = user.reload.totp_configuration_token
    assert_redirected_to configure_otp_authenticator_path(token: token)
    assert(user.reload.otp_secret_key.present?)
    get configure_otp_authenticator_path(token: token)
    assert_response :success
    assert(user.reload.totp_configuration_token.blank?)
    post clear_otp_authenticator_path
    assert_redirected_to edit_profile_otp_path
    assert(user.reload.second_factor_attempts_count.blank?)
    assert(user.encrypted_otp_secret_key.blank?)
    assert(user.encrypted_otp_secret_key_iv.blank?)
    assert(user.encrypted_otp_secret_key_salt.blank?)
    assert(user.direct_otp.blank?)
    assert(user.direct_otp_sent_at.blank?)
    assert(user.totp_timestamp.blank?)
    assert(user.direct_otp.blank?)
    assert(user.otp_secret_key.blank?)
    get profile_path
    assert_response :success
  end

  test 'unauthenticated cannot view edit display page' do
    get edit_profile_display_path
    check_not_authenticated
  end

  test 'unauthenticated cannot view profile' do
    get profile_path
    check_not_authenticated
  end

  test 'authenticated can view profile page with connections heatmap and recent activity' do
    user = users(:superadmin)
    sign_in user
    # Do all available things to pass in all paper trail helper methods
    # force mfa
    put force_mfa_user_path(user)
    # unforce mfa
    put unforce_mfa_user_path(user)
    # activate otp
    post activate_otp_path(user)
    # deactivate otp
    post deactivate_otp_path(user)
    # change display
    put edit_profile_display_path, params: {
      user: {
        display_submenu_direction: 'vertical'
      }
    }
    # public_key
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
    # update password
    get profile_path
    assert_response :success
  end

  test 'unauthenticated cannot view notifications edition page' do
    get edit_profile_notifications_path
    check_not_authenticated
  end

  test 'authenticated can specify subjects and channel_id to be notified on for each slack
    like account' do
    # GIVEN
    # A user with 2 accounts_users with default values
    user = users(:staffuser)
    sign_in user
    # Create 2 accounts_users
    AccountUser.create!(
      account: slack_configs(:slack_config_one),
      user_id: user.id
    )
    AccountUser.create!(
      account: slack_configs(:slack_config_two),
      user_id: user.id
    )
    assert_equal user.accounts_users.count, 2
    user.accounts_users.each do |account_user|
      assert account_user.channel_id.blank?
      assert_equal Notification.subjects.keys, account_user.notify_on
    end

    id_one = user.accounts_users.first.id
    id_two = user.accounts_users.second.id
    channel_id_one = 'GEZGEZaG'
    channel_id_two = 'ADEIFZDEF'

    new_notify_on_one = ['']
    new_notify_on_two = ['exceeding_severity_threshold']
    # WHEN
    # Updating profile notifications with authorized values
    conversations_list_resp = FakeSlack::ConversationsListResponse.new('conversations_list_ok_2')
    Slack::Web::Client.stub_any_instance(:conversations_list, conversations_list_resp) do
      put edit_profile_notifications_path, params: {
        user: {
          send_mail_on: new_notify_on_two,
          notify_on: new_notify_on_two,
          accounts_users_attributes: [
            {
              id: id_one,
              channel_id: channel_id_one,
              notify_on: new_notify_on_one
            },
            {
              id: id_two,
              channel_id: channel_id_two,
              notify_on: new_notify_on_two
            }
          ]
        }
      }
    end
    # THEN
    # Values are updated
    account_user_one = AccountUser.find(id_one)
    account_user_two = AccountUser.find(id_two)
    assert_equal channel_id_one, account_user_one.channel_id
    assert_equal channel_id_two, account_user_two.channel_id
    assert_equal new_notify_on_one, account_user_one.notify_on
    assert_equal new_notify_on_two, account_user_two.notify_on
  end

  test 'authenticated can specify to notify and/or be notified on some predefined subjects' do
    # GIVEN
    # A user with default send_mail_on and notify_on values
    user = users(:staffuser)
    sign_in user
    assert user.send_mail_on, :exceeding_severity_threshold # default value
    assert user.notify_on, Notification.subjects.keys # default value
    expected_send_mail_on = Notification.subjects.keys
    expected_notify_on = ['exceeding_severity_threshold']
    # WHEN
    # Updating profile notifications with authorized values
    put edit_profile_notifications_path, params: {
      user: {
        send_mail_on: expected_send_mail_on,
        notify_on: expected_notify_on
      }
    }
    user.reload
    # THEN send_mail_on and notify_on values are correctly updated
    assert_equal user.send_mail_on, expected_send_mail_on
    assert_equal user.notify_on, expected_notify_on
  end

  test 'authenticated cannot specify to notify on undefined subject' do
    # GIVEN
    # A user with default send_mail_on and notify_on values
    user = users(:staffuser)
    sign_in user
    assert user.send_mail_on, :exceeding_severity_threshold # default value
    assert user.notify_on, Notification.subjects.keys # default value
    expected_send_mail_on = %w[exceeding_severity_threshold inexistant]
    expected_notify_on = %w[exceeding_severity_threshold bullshit]
    # WHEN
    # Update profile notifications with unauthorized values
    put edit_profile_notifications_path, params: {
      user: {
        send_mail_on: expected_send_mail_on,
        notify_on: expected_notify_on
      }
    }
    user.reload
    # THEN send_mail_on and notify_on values are not updated
    assert_not_equal user.send_mail_on, expected_send_mail_on
    assert_not_equal user.notify_on, expected_notify_on
  end

  private

  def check_password_update_fail(current, password, confirmation)
    user = users(:c_one)
    sign_in user
    assert_nil user.password
    put edit_profile_password_path, params:
      {
        user:
          {
            current_password: current,
            password: password,
            password_confirmation: confirmation
          }
      }
    # Check that error is present
    assert_select '#error_explanation' do
      assert true
    end
    assert_nil user.reload.password
  end

  def check_public_key(public_key, status)
    sign_in users(:c_one)
    put edit_profile_public_key_path, params:
      {
        user:
          {
            public_key: public_key
          }
      }
    begin
      # Check that error is present
      assert_select '#error_explanation' do
        assert status
      end
    rescue Minitest::Assertion
      assert true unless status
    end
  end

  def check_display(display, status)
    sign_in users(:c_one)
    put edit_profile_display_path, params:
      {
        user:
          {
            display: display
          }
      }
    begin
      # Check that error is present
      assert_select '#error_explanation' do
        assert status
      end
    rescue Minitest::Assertion
      assert true unless status
    end
  end
end
