# frozen_string_literal: true

require 'test_helper'

class Matrix42ConfigsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'unauthenticated cannot list matrix42_configs' do
    get matrix42_configs_path
    check_not_authenticated
  end

  test 'unauthenticated cannot view new matrix42_config form' do
    get new_matrix42_config_path
    check_not_authenticated
  end

  test 'unauthenticated cannot view edit matrix42_config form' do
    get edit_matrix42_config_path(Matrix42Config.first)
    check_not_authenticated
  end

  test 'unauthenticated cannot view matrix42_config infos' do
    get matrix42_config_path(Matrix42Config.first)
    check_not_authenticated
  end

  test 'unauthenticated cannot create matrix42_configs' do
    post matrix42_configs_path, params:
    {
      matrix42_config:
      {
        name: 'create',
        url: 'https://www.example.com',
        api_url: 'https://www.example.com/m42Services',
        default_ticket_type: 'ticket',
        api_key: 'create',
        supplier_ids: [Client.first.id]
      }
    }
    check_not_authenticated
  end

  test 'unauthenticated cannot update matrix42_config' do
    put matrix42_config_path(Matrix42Config.first), params:
    {
      matrix42_config:
      {
        name: 'update',
        url: 'https://www.example.com',
        api_url: 'https://www.example.com/m42Services',
        default_ticket_type: 'ticket',
        api_key: 'update',
        supplier_ids: [Client.first.id]
      }
    }
    check_not_authenticated
  end

  test 'unauthenticated cannot destroy matrix42_config' do
    delete matrix42_config_path(Matrix42Config.first)
    check_not_authenticated
  end

  test 'authenticated staff superadmin only can list matrix42_config' do
    sign_in users(:staffuser)
    get matrix42_configs_path
    assert_response(302)
    sign_in users(:superadmin)
    get matrix42_configs_path
    assert_response :success
  end

  test 'authenticated staff superadmin only can create matrix42_config' do
    new_name = 'authenticated staff superadmin only can create'
    params = {
      matrix42_config:
      {
        name: new_name,
        url: 'https://www.example.com',
        api_url: 'https://www.example.com/m42Services',
        default_ticket_type: 'ticket',
        api_key: 'create',
        supplier_ids: [Client.first.id]
      }
    }
    # WHEN
    sign_in users(:staffuser)
    post matrix42_configs_path, params: params
    # THEN
    assert_nil Matrix42Config.find_by(name: new_name)
    # WHEN
    sign_in users(:superadmin)
    post matrix42_configs_path, params: params
    # THEN
    snc = Matrix42Config.find_by(name: new_name)
    assert_not_nil snc
  end

  test 'authenticated staff superadmin only can view new matrix42_config form' do
    sign_in users(:staffuser)
    get new_matrix42_config_path
    assert_response(302)
    sign_in users(:superadmin)
    get new_matrix42_config_path
    assert_response :success
  end

  test 'authenticated staff superadmin only can view edit matrix42_config form' do
    sign_in users(:staffuser)
    get edit_matrix42_config_path(Matrix42Config.first)
    assert_response(302)
    sign_in users(:superadmin)
    get edit_matrix42_config_path(Matrix42Config.first)
    assert_response :success
  end

  test 'authenticated staff superadmin only can view matrix42_config infos' do
    sign_in users(:staffuser)
    get matrix42_config_path(Matrix42Config.first)
    assert_response(302)
    sign_in users(:superadmin)
    get matrix42_config_path(Matrix42Config.first)
    assert_response :success
  end

  test 'authenticated staff superadmin only can update matrix42_config' do
    sign_in users(:staffuser)
    new_name = 'authenticated staff superadmin only can update'
    params = {
      matrix42_config:
      {
        name: new_name,
        url: 'https://www.example.com',
        api_url: 'https://www.example.com/m42Services',
        default_ticket_type: 'ticket',
        api_key: 'update',
        supplier_ids: [Client.first.id]
      }
    }
    put matrix42_config_path(Matrix42Config.first), params: params
    assert_nil Matrix42Config.find_by(name: new_name)
    sign_in users(:superadmin)
    put matrix42_config_path(Matrix42Config.first), params: params
    assert_not_nil Matrix42Config.find_by(name: new_name)
  end

  test 'authenticated staff superadmin only can destroy matrix42_config' do
    sign_in users(:staffuser)
    snc = matrix42_configs(:m42_two) # m42_one has Issue and won't be deleted
    delete matrix42_config_path(snc)
    check_unscoped
    sign_in users(:superadmin)
    delete matrix42_config_path(snc)
    assert_equal flash[:notice], I18n.t('matrix42_configs.notices.deletion_success')
  end

  test 'authenticated staff superadmin can destroy matrix42_config only if not used by issue' do
    sign_in users(:superadmin)
    snc = matrix42_configs(:m42_one)
    delete matrix42_config_path(snc)
    check_not_authorized
    snc = matrix42_configs(:m42_two)
    delete matrix42_config_path(snc)
    assert_equal flash[:notice], I18n.t('matrix42_configs.notices.deletion_success')
  end

  test 'authenticated staff superadmin cannot create matrix42_config without name' do
    matrix42_configs_count = Matrix42Config.count
    params = {
      matrix42_config:
      {
        url: 'https://www.example.com',
        api_url: 'https://www.example.com/m42Services',
        default_ticket_type: 'ticket',
        api_key: 'create',
        supplier_ids: [Client.first.id]
      }
    }
    sign_in users(:superadmin)
    post matrix42_configs_path, params: params
    assert_equal(matrix42_configs_count, Matrix42Config.count)
  end

  test 'authenticated staff superadmin cannot create matrix42_config without url' do
    matrix42_configs_count = Matrix42Config.count
    params = {
      matrix42_config:
      {
        name: 'create',
        api_url: 'https://www.example.com/m42Services',
        default_ticket_type: 'ticket',
        api_key: 'create',
        supplier_ids: [Client.first.id]
      }
    }
    sign_in users(:superadmin)
    post matrix42_configs_path, params: params
    assert_equal(matrix42_configs_count, Matrix42Config.count)
  end

  test 'authenticated staff superadmin cannot create matrix42_config without api url' do
    matrix42_configs_count = Matrix42Config.count
    params = {
      matrix42_config:
      {
        name: 'create',
        url: 'https://www.example.com',
        default_ticket_type: 'ticket',
        api_key: 'create',
        supplier_ids: [Client.first.id]
      }
    }
    sign_in users(:superadmin)
    post matrix42_configs_path, params: params
    assert_equal(matrix42_configs_count, Matrix42Config.count)
  end

  test 'authenticated staff superadmin cannot create matrix42_config without ticket type' do
    matrix42_configs_count = Matrix42Config.count
    params = {
      matrix42_config:
      {
        name: 'create',
        url: 'https://www.example.com',
        api_url: 'https://www.example.com/m42Services',
        api_key: 'create',
        supplier_ids: [Client.first.id]
      }
    }
    sign_in users(:superadmin)
    post matrix42_configs_path, params: params
    assert_equal(matrix42_configs_count, Matrix42Config.count)
  end

  test 'authenticated staff superadmin cannot create matrix42_config without api key' do
    matrix42_configs_count = Matrix42Config.count
    params = {
      matrix42_config:
      {
        name: 'create',
        url: 'https://www.example.com',
        api_url: 'https://www.example.com/m42Services',
        default_ticket_type: 'ticket',
        supplier_ids: [Client.first.id]
      }
    }
    sign_in users(:superadmin)
    post matrix42_configs_path, params: params
    assert_equal(matrix42_configs_count, Matrix42Config.count)
  end

  test 'authenticated staff superadmin cannot update matrix42_config without name' do
    sign_in users(:superadmin)
    matrix42_config = Matrix42Config.first
    original_name = matrix42_config.name
    params = {
      matrix42_config:
      {
        name: nil,
        url: 'https://www.example.com',
        api_url: 'https://www.example.com/m42Services',
        default_ticket_type: 'ticket',
        api_key: 'update',
        supplier_ids: [Client.first.id]
      }
    }
    put matrix42_config_path(matrix42_config), params: params
    assert_equal matrix42_config, Matrix42Config.find_by(name: original_name)
  end

  test 'authenticated staff superadmin cannot update matrix42_config without url' do
    sign_in users(:superadmin)
    matrix42_config = Matrix42Config.first
    original_name = matrix42_config.name
    params = {
      matrix42_config:
      {
        name: 'update',
        url: nil,
        api_url: 'https://www.example.com/m42Services',
        default_ticket_type: 'ticket',
        api_key: 'update',
        supplier_ids: [Client.first.id]
      }
    }
    put matrix42_config_path(matrix42_config), params: params
    assert_equal matrix42_config, Matrix42Config.find_by(name: original_name)
  end

  test 'authenticated staff superadmin cannot update matrix42_config without api url' do
    sign_in users(:superadmin)
    matrix42_config = Matrix42Config.first
    original_name = matrix42_config.name
    params = {
      matrix42_config:
      {
        name: 'update',
        url: 'https://www.example.com',
        api_url: nil,
        default_ticket_type: 'ticket',
        api_key: 'update',
        supplier_ids: [Client.first.id]
      }
    }
    put matrix42_config_path(matrix42_config), params: params
    assert_equal matrix42_config, Matrix42Config.find_by(name: original_name)
  end

  test 'authenticated staff superadmin cannot update matrix42_config without ticket type' do
    sign_in users(:superadmin)
    matrix42_config = Matrix42Config.first
    original_name = matrix42_config.name
    params = {
      matrix42_config:
      {
        name: 'update',
        url: 'https://www.example.com',
        api_url: 'https://www.example.com/m42Services',
        default_ticket_type: nil,
        api_key: 'update',
        supplier_ids: [Client.first.id]
      }
    }
    put matrix42_config_path(matrix42_config), params: params
    assert_equal matrix42_config, Matrix42Config.find_by(name: original_name)
  end

  test 'authenticated staff superadmin can update matrix42_config without api key' do
    sign_in users(:superadmin)
    matrix42_config = Matrix42Config.first
    new_name = "#{matrix42_config.name}-update"
    original_api_key = matrix42_config.api_key
    params = {
      matrix42_config:
      {
        name: new_name,
        url: 'https://www.example.com',
        api_url: 'https://www.example.com/m42Services',
        default_ticket_type: 'ticket',
        api_key: '',
        supplier_ids: [Client.first.id]
      }
    }
    put matrix42_config_path(matrix42_config), params: params
    assert_equal matrix42_config, Matrix42Config.find_by(name: new_name)
    assert_equal original_api_key, Matrix42Config.find_by(name: new_name).api_key
  end
end
