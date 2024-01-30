# frozen_string_literal: true

require 'test_helper'

class ContactsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'unauthenticated cannot force activate contact' do
    put activate_contact_path(User.contacts.inactif.first)
    check_not_authenticated
  end

  test 'authenticated staff can force activate contact' do
    contact = User.contacts.inactif.first
    sign_in users(:staffuser)
    put activate_contact_path(contact)
    assert_equal I18n.t('users.notices.activated'), flash[:notice]
    assert User.contacts.find(contact.id).actif?
  end

  test 'unauthenticated cannot undiscard contact' do
    put restore_contact_path(User.contacts.first)
    check_not_authenticated
  end

  test 'authenticated staff can undiscard contact' do
    contact = User.contacts.first
    contact.discard
    sign_in users(:staffuser)
    put restore_contact_path(contact.id)
    assert_equal I18n.t('users.notices.restored'), flash[:notice]
    assert_not User.contacts.find(contact.id).discarded?
  end

  test 'authenticated contact cannot create contact' do
    sign_in users(:contactmanager)
    post contacts_path, params:
    {
      contact:
      {
        ref_identifier: 7357,
        full_name: 'test',
        email: 'test@test.test'
      }
    }
    assert_redirected_to root_path
  end

  test 'authenticated contact with role admin_contact cannot create contact without client' do
    sign_in users(:contactadmin)
    post contacts_path, params:
    {
      contact:
      {
        full_name: 'test',
        email: 'test@test.test',
        contact_client_ids: ['']
      }
    }
    assert_equal I18n.t('contacts.notices.teams_selection'), flash[:alert]
  end

  test 'authenticated contact with role admin_contact can create contact' do
    sign_in users(:contactadmin)
    post contacts_path, params:
    {
      contact:
      {
        full_name: 'test',
        email: 'test@test.test',
        contact_client_ids: ['', Client.first.id]
      }
    }
    assert_not_nil User.contacts.find_by(full_name: 'test')
  end

  test 'authenticated contact with role admin_contact cannot remove own contact_admin role' do
    contact = users(:contactadmin)
    sign_in contact
    put contact_path(contact), params:
    {
      contact:
      {
        full_name: 'test',
        email: 'test@test.test',
        contact_client_ids: ['', Client.first.id],
        role_ids: ['']
      }
    }
    updated_contact = User.contacts.find(contact.id)
    assert_equal 'test', updated_contact.full_name
    assert_not_nil updated_contact.roles.find_by(name: 'contact_admin')
  end

  # Force reset password
  test 'authenticated super_admin can update contact password without old password' do
    c = users(:c_one)
    sign_in users(:superadmin)
    new_pass = 'NewLongP@ssW0rd!'
    put force_reset_password_contact_path(c), params:
      {
        user:
          {
            id: c.id,
            password: new_pass,
            password_confirmation: 'somethingElse'
          }
      }
    assert_equal I18n.t('users.notices.password_fail'), flash[:alert]
    assert_not(User.contacts.find(c.id).valid_password?(new_pass))
    put force_reset_password_contact_path(c), params:
      {
        user:
          {
            id: c.id,
            password: new_pass,
            password_confirmation: new_pass
          }
      }
    assert User.contacts.find(c.id).valid_password?(new_pass)
  end

  # Force update email
  test 'authenticated super_admin can update contact email without having to confirm' do
    con = users(:c_one)
    sign_in users(:superadmin)
    new_email = 'new.email@somedomain.eu'
    put force_update_email_contact_path(con), params:
      {
        user:
          {
            id: con.id,
            email: new_email
          }
      }
    contact = User.contacts.find(con.id)
    assert_equal new_email, contact.email
    assert contact.confirmed?
  end

  # Force confirm email
  test 'authenticated super_admin can force contact email confirmation' do
    con = User.contacts.find(users(:c_one).id)
    con.update(confirmed_at: nil)
    assert_not con.confirmed?
    sign_in users(:superadmin)
    put force_confirm_contact_path(con)
    assert con.reload.confirmed?
  end

  # Force deactivate otp
  test 'authenticated super_admin can force contact otp deactivation' do
    con = User.contacts.find(users(:c_one).id)
    con.activate_otp
    assert con.otp_activated?
    sign_in users(:superadmin)
    put force_deactivate_otp_contact_path(con)
    assert_not con.reload.otp_activated?
  end

  # Force unlock otp
  test 'authenticated super_admin can force contact otp unlock' do
    con = User.contacts.find(users(:c_one).id)
    con.update(second_factor_attempts_count: 3)
    assert con.max_login_attempts?
    sign_in users(:superadmin)
    put force_unlock_otp_contact_path(con)
    assert_not con.reload.max_login_attempts?
  end
end
