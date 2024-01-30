# frozen_string_literal: true

require 'test_helper'

class SellsyConfigsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'unauthenticated cannot list sellsy_configs' do
    get sellsy_configs_path
    check_not_authenticated
  end

  test 'unauthenticated cannot create sellsy_config' do
    post sellsy_configs_path, params:
    {
      sellsy_config:
      {
        name: 'test',
        login: 'test',
        password: 'test'
      }
    }
    check_not_authenticated
  end

  test 'Super Admin can list sellsy_configs' do
    sign_in users(:superadmin)
    get sellsy_configs_path
    assert_select 'main table.table' do
      SellsyConfig.page(1).each do |sellsy_config|
        assert_select 'td', text: sellsy_config.name
      end
    end
  end

  test 'authenticated staff superadmin only can create sellsy_config' do
    sign_in users(:staffuser)
    new_name = 'test'
    params = {
      sellsy_config:
      {
        name: new_name,
        consumer_token: 'test',
        user_token: 'test',
        consumer_secret: 'test',
        user_secret: 'test'
      }
    }
    post sellsy_configs_path, params: params
    assert_nil SellsyConfig.find_by(name: new_name)
    sign_in users(:superadmin)
    post sellsy_configs_path, params: params
    assert_not_nil SellsyConfig.find_by(name: new_name)
  end

  test 'unauthenticated cannot view new sellsy_config form' do
    get new_sellsy_config_path
    check_not_authenticated
  end

  test 'unauthenticated cannot view edit sellsy_config form' do
    get edit_sellsy_config_path(SellsyConfig.first)
    check_not_authenticated
  end

  test 'unauthenticated cannot view sellsy_config infos' do
    get sellsy_config_path(SellsyConfig.first)
    check_not_authenticated
  end

  test 'unauthenticated cannot update sellsy_config' do
    params = {
      sellsy_config:
      {
        name: 'new_name',
        consumer_token: 'test',
        user_token: 'test',
        consumer_secret: 'test',
        user_secret: 'test'
      }
    }
    put sellsy_config_path(SellsyConfig.first), params: params
    check_not_authenticated
  end

  test 'unauthenticated cannot destroy sellsy_config' do
    delete sellsy_config_path(SellsyConfig.first)
    check_not_authenticated
  end

  test 'authenticated staff superadmin only can view new sellsy_config form' do
    sign_in users(:staffuser)
    get new_sellsy_config_path
    assert_response(302)
    sign_in users(:superadmin)
    get new_sellsy_config_path
    assert_response :success
  end

  test 'authenticated staff superadmin only can view edit sellsy_config form' do
    sign_in users(:staffuser)
    get edit_sellsy_config_path(SellsyConfig.first)
    assert_response(302)
    sign_in users(:superadmin)
    get edit_sellsy_config_path(SellsyConfig.first)
    assert_response :success
  end

  test 'authenticated staff superadmin only can view sellsy_config infos' do
    sign_in users(:staffuser)
    get sellsy_config_path(SellsyConfig.first)
    assert_response(302)
    sign_in users(:superadmin)
    get sellsy_config_path(SellsyConfig.first)
    assert_response :success
  end

  test 'authenticated staff superadmin only can update sellsy_config' do
    sign_in users(:staffuser)
    new_name = 'update'
    params = {
      sellsy_config:
      {
        name: 'update',
        consumer_token: 'test',
        user_token: 'test',
        consumer_secret: 'test',
        user_secret: 'test'
      }
    }
    put sellsy_config_path(SellsyConfig.first), params: params
    assert_nil SellsyConfig.find_by(name: new_name)
    sign_in users(:superadmin)
    put sellsy_config_path(SellsyConfig.first), params: params
    assert_not_nil SellsyConfig.find_by(name: new_name)
  end

  test 'authenticated staff superadmin only can destroy sellsy_config' do
    sign_in users(:staffuser)
    delete sellsy_config_path(SellsyConfig.first)
    assert_response(302)
    sign_in users(:superadmin)
    delete sellsy_config_path(SellsyConfig.first)
    assert_equal flash[:notice], I18n.t('sellsy_configs.notices.deletion_success')
  end

  test 'authenticated staff superadmin only can create new sellsy_config' do
    sign_in users(:staffuser)
    new_name = 'dudu'
    params = {
      sellsy_config:
      {
        name: new_name,
        consumer_token: 'test',
        user_token: 'test',
        consumer_secret: 'test',
        user_secret: 'test'
      }
    }
    post sellsy_configs_path, params: params
    assert_nil SellsyConfig.find_by(name: new_name)
    sign_in users(:superadmin)
    post sellsy_configs_path, params: params
    assert_not_nil SellsyConfig.find_by(name: new_name)
  end

  test 'authenticated staff superadmin cannot create new sellsy_config without name' do
    sign_in users(:superadmin)
    sellsy_configs_count = SellsyConfig.count
    params = {
      sellsy_config:
      {
        consumer_token: 'test',
        user_token: 'test',
        consumer_secret: 'test',
        user_secret: 'test'
      }
    }
    post sellsy_configs_path, params: params
    assert_equal sellsy_configs_count, SellsyConfig.count
  end

  test 'authenticated staff superadmin cannot create new sellsy_config without consumer_token' do
    sign_in users(:superadmin)
    params = {
      sellsy_config:
      {
        name: 'dudu',
        user_token: 'test',
        consumer_secret: 'test',
        user_secret: 'test'
      }
    }
    post sellsy_configs_path, params: params
    assert_nil SellsyConfig.find_by(name: 'dudu')
  end

  test 'authenticated staff superadmin cannot create new sellsy_config without user_token' do
    sign_in users(:staffuser)
    params = {
      sellsy_config:
      {
        name: 'dudu',
        consumer_token: 'test',
        consumer_secret: 'test',
        user_secret: 'test'
      }
    }
    post sellsy_configs_path, params: params
    assert_nil SellsyConfig.find_by(name: 'dudu')
  end

  test 'authenticated staff superadmin cannot create new sellsy_config without consumer_secret' do
    sign_in users(:staffuser)
    params = {
      sellsy_config:
      {
        name: 'dudu',
        consumer_token: 'test',
        user_token: 'test',
        user_secret: 'test'
      }
    }
    post sellsy_configs_path, params: params
    assert_nil SellsyConfig.find_by(name: 'dudu')
  end

  test 'authenticated staff superadmin cannot create new sellsy_config without user_secret' do
    sign_in users(:staffuser)
    params = {
      sellsy_config:
      {
        name: 'dudu',
        consumer_token: 'test',
        user_token: 'test',
        consumer_secret: 'test'
      }
    }
    post sellsy_configs_path, params: params
    assert_nil SellsyConfig.find_by(name: 'dudu')
  end

  test 'authenticated staff superadmin cannot update sellsy_config without name' do
    sign_in users(:superadmin)
    sellsy_config = SellsyConfig.first
    original_name = sellsy_config.name
    original_consumer_token = sellsy_config.consumer_token
    params = {
      sellsy_config:
      {
        name: nil,
        consumer_token: 'test',
        user_token: 'test',
        consumer_secret: 'test',
        user_secret: 'test'
      }
    }
    put sellsy_config_path(sellsy_config), params: params
    assert_equal original_consumer_token, SellsyConfig.find_by(name: original_name).consumer_token
  end

  test 'authenticated staff superadmin can update sellsy_config without changing consumer_token' do
    sign_in users(:superadmin)
    sc = SellsyConfig.first
    new_name = 'update'
    params = {
      sellsy_config:
      {
        name: new_name,
        consumer_token: nil,
        user_token: 'test',
        consumer_secret: 'test',
        user_secret: 'test'
      }
    }
    put sellsy_config_path(sc), params: params
    assert_equal sc.consumer_token, SellsyConfig.find_by(name: new_name).consumer_token
  end

  test 'authenticated staff can update sellsy_config without changing user_token' do
    sign_in users(:superadmin)
    sc = SellsyConfig.first
    new_name = 'update'
    params = {
      sellsy_config:
      {
        name: new_name,
        consumer_token: 'test',
        user_token: nil,
        consumer_secret: 'test',
        user_secret: 'test'
      }
    }
    put sellsy_config_path(sc), params: params
    assert_equal sc.user_token, SellsyConfig.find_by(name: new_name).user_token
  end

  test 'authenticated staff superadmin can update sellsy_config w\out changing consumer_secret' do
    sign_in users(:superadmin)
    sc = SellsyConfig.first
    new_name = 'update'
    params = {
      sellsy_config:
      {
        name: new_name,
        consumer_token: 'test',
        user_token: 'test',
        consumer_secret: nil,
        user_secret: 'test'
      }
    }
    put sellsy_config_path(sc), params: params
    assert_equal sc.consumer_secret, SellsyConfig.find_by(name: new_name).consumer_secret
  end

  test 'authenticated staff can update sellsy_config without changing user_secret' do
    sign_in users(:superadmin)
    sc = SellsyConfig.first
    new_name = 'update'
    params = {
      sellsy_config:
      {
        name: new_name,
        consumer_token: 'test',
        user_token: 'test',
        consumer_secret: 'test',
        user_secret: nil
      }
    }
    put sellsy_config_path(sc), params: params
    assert_equal sc.user_secret, SellsyConfig.find_by(name: new_name).user_secret
  end

  # Imports

  test 'unauthenticated cannot import clients' do
    post sellsy_config_import_path(SellsyConfig.first)
    check_not_authenticated
  end

  test 'authenticated super_admin only can import clients' do
    sign_in users(:staffuser)
    post sellsy_config_import_path(SellsyConfig.first)
    check_not_authorized
    sign_in users(:superadmin)
    post sellsy_config_import_path(SellsyConfig.first)
    assert_equal flash[:notice], I18n.t('settings.import_sellsy')
  end
end
