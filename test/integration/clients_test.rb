# frozen_string_literal: true

require 'test_helper'

class ClientsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'unauthenticated cannot list clients' do
    get clients_path
    check_not_authenticated
  end

  test 'unauthenticated cannot consult clients' do
    client = Client.first
    get "/clients/#{client.id}"
    check_not_authenticated
  end

  test 'unauthenticated cannot know if a client exists' do
    get '/clients/ABC'
    check_not_authenticated
  end

  test 'authenticated staff can list clients' do
    sign_in users(:staffuser)
    get clients_path
    assert_select 'main table.table' do |table|
      Client.where(internal_type: :client).page(1).each do |client|
        assert_select table, 'td/a/span', text: client.name
        assert_select table, 'td/a', text: client.web_url
      end
    end
  end

  test 'authenticated staff can filter clients by name containing' do
    sign_in users(:staffuser)
    get clients_path, params: { q: { name_cont: 'dev' } }
    assert_select 'main table.table' do |table|
      client = Client.find_by(ref_identifier: 'SELLSY_0002')
      assert_select table, 'td/a/span', text: client.name
      assert_select table, 'td/a', text: client.web_url
    end
  end

  test 'authenticated staff can view scoped client which has an URL' do
    sign_in users(:staffuser)
    c = Client.where.not(web_url: nil).first
    get "/clients/#{c.id}"
    assert_select 'h4', text: c.name
    assert_select 'td', text: c.web_url
  end

  test 'authenticated staff can view scoped client which has no URL' do
    sign_in users(:staffuser)
    c = Client.find_by(web_url: nil)
    get "/clients/#{c.id}"
    assert_select 'h4', text: c.name
    assert_select 'td', text: c.web_url
  end

  test 'authenticated staff cannot consult inexistant client' do
    sign_in users(:staffuser)
    get '/clients/ABC'
    assert_redirected_to clients_path
  end

  test 'unauthenticated cannot create clients' do
    post clients_path, params:
    {
      client:
      {
        ref_identifier: 7357,
        name: 'test',
        internal_type: 'client'
      }
    }
    check_not_authenticated
  end

  test 'authenticated staff can create clients' do
    sign_in users(:staffuser)
    post clients_path, params:
    {
      client:
      {
        ref_identifier: 7357,
        name: 'test',
        internal_type: 'client'
      }
    }
    assert_not_nil Client.find_by(name: 'test')
  end

  test 'unauthenticated cannot view new client form' do
    get new_client_path
    check_not_authenticated
  end

  test 'unauthenticated cannot view edit client form' do
    get edit_client_path(Client.first)
    check_not_authenticated
  end

  test 'unauthenticated cannot update clients' do
    put client_path(Client.first), params:
    {
      client:
      {
        name: 'update'
      }
    }
    check_not_authenticated
  end

  test 'unauthenticated cannot destroy client' do
    delete client_path(Client.first)
    check_not_authenticated
  end

  test 'authenticated staff can view new client form' do
    sign_in users(:staffuser)
    get new_client_path
    assert_response :success
  end

  test 'authenticated staff can view edit scoped client' do
    sign_in users(:staffuser)
    get edit_client_path(clients(:client_one))
    assert_response :success
  end

  # staffuser => team1 => projects one or two => client one or two
  # clients(:xxx) is xxx client from fixtures
  # Client.second is second client from all clients list which is ordered by some specific rule
  test 'authenticated staff can update scoped clients' do
    sign_in users(:staffuser)
    new_name = 'update'
    put client_path(clients(:client_two)), params: { client: { name: new_name } }
    assert_not_nil Client.find_by(name: new_name)
  end

  test 'authenticated staff can destroy client' do
    sign_in users(:staffuser)
    delete client_path(Client.first)
    assert_equal flash[:notice], I18n.t('clients.notices.deletion_success')
  end

  test 'authenticated staff cannot create new client without name' do
    sign_in users(:staffuser)
    post clients_path, params:
    {
      client:
      {
        name: nil
      }
    }
    assert_response(200)
  end

  test 'authenticated staff cannot update client without name' do
    sign_in users(:staffuser)
    put client_path(Client.first), params:
    {
      client:
      {
        name: nil
      }
    }
    assert_response(200)
  end

  # 2FA
  test 'unauthenticated cannot force_mfa on a client' do
    put force_mfa_client_path(Client.first)
    check_not_authenticated
  end

  test 'authenticated super_admin only can force_mfa on a client only if not already forced' do
    client = Client.first
    assert_not(client.otp_mandatory?)
    sign_in users(:staffuser)
    put force_mfa_client_path(client)
    check_not_authorized # Not superadmin
    sign_in users(:superadmin)
    put force_mfa_client_path(client)
    assert_redirected_to root_path # back in history
    assert(client.reload.otp_mandatory?)
  end

  test 'unauthenticated cannot unforce_mfa on a client' do
    put unforce_mfa_client_path(Client.first)
    check_not_authenticated
  end

  test 'authenticated super_admin only can unforce_mfa on a client only if already forced' do
    client = Client.first
    assert_not(client.otp_mandatory?)
    sign_in users(:staffuser)
    put unforce_mfa_client_path(client)
    check_not_authorized # Not superadmin
    sign_in users(:superadmin)
    put unforce_mfa_client_path(client)
    check_not_authorized
    put force_mfa_client_path(client)
    assert_redirected_to root_path # back in history
    assert(client.reload.otp_mandatory?)
    put unforce_mfa_client_path(client)
    assert_redirected_to root_path # back in history = last get
    assert_not(client.reload.otp_mandatory?)
  end
end
