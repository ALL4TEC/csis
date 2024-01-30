# frozen_string_literal: true

require 'test_helper'

class ServicenowConfigsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'unauthenticated cannot list servicenow_configs' do
    get servicenow_configs_path
    check_not_authenticated
  end

  test 'unauthenticated cannot view new servicenow_config form' do
    get new_servicenow_config_path
    check_not_authenticated
  end

  test 'unauthenticated cannot view edit servicenow_config form' do
    get edit_servicenow_config_path(ServicenowConfig.first)
    check_not_authenticated
  end

  test 'unauthenticated cannot view servicenow_config infos' do
    get servicenow_config_path(ServicenowConfig.first)
    check_not_authenticated
  end

  test 'unauthenticated cannot create servicenow_configs' do
    post servicenow_configs_path, params:
    {
      servicenow_config:
      {
        name: 'update',
        url: 'https://update.example.com',
        api_key: 'update',
        secret_key: 'update',
        fixed_vuln: 'update',
        accepted_risk: 'update',
        supplier_ids: [Client.first.id]
      }
    }
    check_not_authenticated
  end

  test 'unauthenticated cannot update servicenow_config' do
    put servicenow_config_path(ServicenowConfig.first), params:
    {
      servicenow_config:
      {
        name: 'update',
        url: 'https://update.example.com',
        api_key: 'update',
        secret_key: 'update',
        fixed_vuln: 'update',
        accepted_risk: 'update',
        supplier_ids: [Client.first.id]
      }
    }
    check_not_authenticated
  end

  test 'unauthenticated cannot destroy servicenow_config' do
    delete servicenow_config_path(ServicenowConfig.first)
    check_not_authenticated
  end

  test 'authenticated staff superadmin only can list servicenow_config' do
    sign_in users(:staffuser)
    get servicenow_configs_path
    assert_response(302)
    sign_in users(:superadmin)
    get servicenow_configs_path
    assert_response :success
  end

  test 'authenticated staff superadmin only can create servicenow_config' do
    new_name = 'authenticated staff superadmin only can create'
    params = {
      servicenow_config:
      {
        name: new_name,
        url: 'https://create.example.com',
        api_key: 'create',
        secret_key: 'create',
        fixed_vuln: 'create',
        accepted_risk: 'create',
        supplier_ids: [Client.first.id]
      }
    }
    # WHEN
    sign_in users(:staffuser)
    post servicenow_configs_path, params: params
    # THEN
    assert_nil ServicenowConfig.find_by(name: new_name)
    # WHEN
    sign_in users(:superadmin)
    post servicenow_configs_path, params: params
    # THEN
    snc = ServicenowConfig.find_by(name: new_name)
    assert_not_nil snc
  end

  test 'authenticated staff superadmin only can view new servicenow_config form' do
    sign_in users(:staffuser)
    get new_servicenow_config_path
    assert_response(302)
    sign_in users(:superadmin)
    get new_servicenow_config_path
    assert_response :success
  end

  test 'authenticated staff superadmin only can view edit servicenow_config form' do
    sign_in users(:staffuser)
    get edit_servicenow_config_path(ServicenowConfig.first)
    assert_response(302)
    sign_in users(:superadmin)
    get edit_servicenow_config_path(ServicenowConfig.first)
    assert_response :success
  end

  test 'authenticated staff superadmin only can view servicenow_config infos' do
    sign_in users(:staffuser)
    get servicenow_config_path(ServicenowConfig.first)
    assert_response(302)
    sign_in users(:superadmin)
    get servicenow_config_path(ServicenowConfig.first)
    assert_response :success
  end

  test 'authenticated staff superadmin only can update servicenow_config' do
    sign_in users(:staffuser)
    new_name = 'authenticated staff superadmin only can update'
    params = {
      servicenow_config:
      {
        name: new_name,
        url: 'https://update.example.com',
        api_key: 'update',
        secret_key: 'update',
        fixed_vuln: 'update',
        accepted_risk: 'update',
        supplier_ids: [Client.first.id]
      }
    }
    put servicenow_config_path(ServicenowConfig.first), params: params
    assert_nil ServicenowConfig.find_by(name: new_name)
    sign_in users(:superadmin)
    put servicenow_config_path(ServicenowConfig.first), params: params
    assert_not_nil ServicenowConfig.find_by(name: new_name)
  end

  test 'authenticated staff superadmin only can destroy servicenow_config' do
    sign_in users(:staffuser)
    snc = servicenow_configs(:snc_two) # snc_one has Issue and won't be deleted
    delete servicenow_config_path(snc)
    check_unscoped
    sign_in users(:superadmin)
    delete servicenow_config_path(snc)
    assert_equal flash[:notice], I18n.t('servicenow_configs.notices.deletion_success')
  end

  test 'authenticated staff superadmin can destroy servicenow_config only if not used by issue' do
    sign_in users(:superadmin)
    snc = servicenow_configs(:snc_one)
    delete servicenow_config_path(snc)
    check_not_authorized
    snc = servicenow_configs(:snc_two)
    delete servicenow_config_path(snc)
    assert_equal flash[:notice], I18n.t('servicenow_configs.notices.deletion_success')
  end

  test 'authenticated staff superadmin cannot create servicenow_config without name' do
    servicenow_configs_count = ServicenowConfig.count
    params = {
      servicenow_config:
      {
        url: 'https://create.example.com',
        api_key: 'create',
        secret_key: 'create',
        fixed_vuln: 'create',
        accepted_risk: 'create',
        supplier_ids: [Client.first.id]
      }
    }
    sign_in users(:superadmin)
    post servicenow_configs_path, params: params
    assert_equal(servicenow_configs_count, ServicenowConfig.count)
  end

  test 'authenticated staff superadmin cannot create servicenow_config without url' do
    servicenow_configs_count = ServicenowConfig.count
    params = {
      servicenow_config:
      {
        name: 'create',
        api_key: 'create',
        secret_key: 'create',
        fixed_vuln: 'create',
        accepted_risk: 'create',
        supplier_ids: [Client.first.id]
      }
    }
    sign_in users(:superadmin)
    post servicenow_configs_path, params: params
    assert_equal(servicenow_configs_count, ServicenowConfig.count)
  end

  test 'authenticated staff superadmin cannot create servicenow_config without client id' do
    servicenow_configs_count = ServicenowConfig.count
    params = {
      servicenow_config:
      {
        name: 'create',
        url: 'https://create.example.com',
        secret_key: 'create',
        fixed_vuln: 'create',
        accepted_risk: 'create',
        supplier_ids: [Client.first.id]
      }
    }
    sign_in users(:superadmin)
    post servicenow_configs_path, params: params
    assert_equal(servicenow_configs_count, ServicenowConfig.count)
  end

  test 'authenticated staff superadmin cannot create servicenow_config without client secret' do
    servicenow_configs_count = ServicenowConfig.count
    params = {
      servicenow_config:
      {
        name: 'create',
        url: 'https://create.example.com',
        api_key: 'create',
        fixed_vuln: 'create',
        accepted_risk: 'create',
        supplier_ids: [Client.first.id]
      }
    }
    sign_in users(:superadmin)
    post servicenow_configs_path, params: params
    assert_equal(servicenow_configs_count, ServicenowConfig.count)
  end

  test 'authenticated staff superadmin cannot create servicenow_config without resolution codes' do
    servicenow_configs_count = ServicenowConfig.count
    params = {
      servicenow_config:
      {
        name: 'create',
        url: 'https://create.example.com',
        api_key: 'create',
        secret_key: 'create',
        supplier_ids: [Client.first.id]
      }
    }
    sign_in users(:superadmin)
    post servicenow_configs_path, params: params
    assert_equal(servicenow_configs_count, ServicenowConfig.count)
  end

  test 'authenticated staff superadmin cannot update servicenow_config without name' do
    sign_in users(:superadmin)
    servicenow_config = ServicenowConfig.first
    original_name = servicenow_config.name
    params = {
      servicenow_config:
      {
        name: nil,
        url: 'https://update.example.com',
        api_key: 'update',
        secret_key: 'update',
        fixed_vuln: 'update',
        accepted_risk: 'update',
        supplier_ids: [Client.first.id]
      }
    }
    put servicenow_config_path(servicenow_config), params: params
    assert_equal servicenow_config, ServicenowConfig.find_by(name: original_name)
  end

  test 'authenticated staff superadmin cannot update servicenow_config without address' do
    sign_in users(:superadmin)
    servicenow_config = ServicenowConfig.first
    original_name = servicenow_config.name
    params = {
      servicenow_config:
      {
        name: 'update',
        url: nil,
        api_key: 'update',
        secret_key: 'update',
        fixed_vuln: 'update',
        accepted_risk: 'update',
        supplier_ids: [Client.first.id]
      }
    }
    put servicenow_config_path(servicenow_config), params: params
    assert_equal servicenow_config, ServicenowConfig.find_by(name: original_name)
  end

  test 'authenticated staff superadmin can update servicenow_config without client id' do
    sign_in users(:superadmin)
    servicenow_config = ServicenowConfig.first
    new_name = "#{servicenow_config.name}-update"
    original_client_id = servicenow_config.api_key
    params = {
      servicenow_config:
      {
        name: new_name,
        url: 'https://update.example.com',
        api_key: '',
        secret_key: 'update',
        fixed_vuln: 'update',
        accepted_risk: 'update',
        supplier_ids: [Client.first.id]
      }
    }
    put servicenow_config_path(servicenow_config), params: params
    assert_equal servicenow_config, ServicenowConfig.find_by(name: new_name)
    assert_equal original_client_id, ServicenowConfig.find_by(name: new_name).api_key
  end

  test 'authenticated staff superadmin can update servicenow_config without client secret' do
    sign_in users(:superadmin)
    servicenow_config = ServicenowConfig.first
    new_name = "#{servicenow_config.name}-update"
    original_client_secret = servicenow_config.secret_key
    params = {
      servicenow_config:
      {
        name: new_name,
        url: 'https://update.example.com',
        api_key: 'update',
        secret_key: '',
        fixed_vuln: 'update',
        accepted_risk: 'update',
        supplier_ids: [Client.first.id]
      }
    }
    put servicenow_config_path(servicenow_config), params: params
    assert_equal servicenow_config, ServicenowConfig.find_by(name: new_name)
    assert_equal original_client_secret, ServicenowConfig.find_by(name: new_name).secret_key
  end

  test 'authenticated staff superadmin cannot update servicenow_config without resolution codes' do
    sign_in users(:superadmin)
    servicenow_config = ServicenowConfig.first
    original_name = servicenow_config.name
    params = {
      servicenow_config:
      {
        name: 'update',
        url: 'https://update.example.com',
        api_key: 'update',
        secret_key: 'update',
        fixed_vuln: nil,
        accepted_risk: nil,
        supplier_ids: [Client.first.id]
      }
    }
    put servicenow_config_path(servicenow_config), params: params
    assert_equal servicenow_config, ServicenowConfig.find_by(name: original_name)
  end
end
