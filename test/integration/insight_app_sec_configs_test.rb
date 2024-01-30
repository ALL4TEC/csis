# frozen_string_literal: true

require 'test_helper'

class InsightAppSecConfigsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'unauthenticated cannot list insight_app_sec_configs' do
    get insight_app_sec_configs_path
    check_not_authenticated
  end

  test 'unauthenticated cannot create insight_app_sec_config' do
    post insight_app_sec_configs_path, params:
    {
      insight_app_sec_config:
      {
        name: 'test',
        url: 'url',
        api_key: 'test'
      }
    }
    check_not_authenticated
  end

  test 'Super Admin can list insight_app_sec_configs' do
    sign_in users(:superadmin)
    get insight_app_sec_configs_path
    assert_select 'main table.table' do
      InsightAppSecConfig.page(1).each do |insight_app_sec_config|
        assert_select 'td', text: insight_app_sec_config.name
      end
    end
  end

  test 'authenticated staff superadmin only can create insight_app_sec_config' do
    sign_in users(:staffuser)
    new_name = 'test'
    params = {
      insight_app_sec_config:
      {
        name: new_name,
        url: 'url',
        api_key: 'test',
        team_ids: [Team.first.id]
      }
    }
    post insight_app_sec_configs_path, params: params
    assert_nil InsightAppSecConfig.find_by(name: new_name)
    sign_in users(:superadmin)
    post insight_app_sec_configs_path, params: params
    assert_not_nil InsightAppSecConfig.find_by(name: new_name)
  end

  test 'unauthenticated cannot view new insight_app_sec_config form' do
    get new_insight_app_sec_config_path
    check_not_authenticated
  end

  test 'unauthenticated cannot view edit insight_app_sec_config form' do
    get edit_insight_app_sec_config_path(InsightAppSecConfig.first)
    check_not_authenticated
  end

  test 'unauthenticated cannot view insight_app_sec_config infos' do
    get insight_app_sec_config_path(InsightAppSecConfig.first)
    check_not_authenticated
  end

  test 'unauthenticated cannot update insight_app_sec_config' do
    put insight_app_sec_config_path(InsightAppSecConfig.first), params:
    {
      staff:
      {
        name: 'update',
        url: 'url',
        api_key: 'update',
        team_ids: [Team.first.id]
      }
    }
    check_not_authenticated
  end

  test 'unauthenticated cannot destroy insight_app_sec_config' do
    delete insight_app_sec_config_path(InsightAppSecConfig.first)
    check_not_authenticated
  end

  test 'authenticated staff superadmin only can view new insight_app_sec_config form' do
    sign_in users(:staffuser)
    get new_insight_app_sec_config_path
    assert_response(302)
    sign_in users(:superadmin)
    get new_insight_app_sec_config_path
    assert_response :success
  end

  test 'authenticated staff superadmin only can view edit insight_app_sec_config form' do
    sign_in users(:staffuser)
    get edit_insight_app_sec_config_path(InsightAppSecConfig.first)
    assert_response(302)
    sign_in users(:superadmin)
    get edit_insight_app_sec_config_path(InsightAppSecConfig.first)
    assert_response :success
  end

  test 'authenticated staff superadmin only can view insight_app_sec_config infos' do
    sign_in users(:staffuser)
    get insight_app_sec_config_path(InsightAppSecConfig.first)
    assert_response(302)
    sign_in users(:superadmin)
    get insight_app_sec_config_path(InsightAppSecConfig.first)
    assert_response :success
  end

  test 'authenticated staff superadmin only can update insight_app_sec_config' do
    sign_in users(:staffuser)
    new_name = 'update'
    put insight_app_sec_config_path(InsightAppSecConfig.first), params:
    {
      insight_app_sec_config:
      {
        name: new_name,
        url: 'url',
        api_key: 'update',
        team_ids: [Team.first.id]
      }
    }
    assert_nil InsightAppSecConfig.find_by(name: new_name)
    sign_in users(:superadmin)
    put insight_app_sec_config_path(InsightAppSecConfig.first), params:
    {
      insight_app_sec_config:
      {
        name: new_name,
        url: 'url',
        api_key: 'update',
        team_ids: [Team.first.id]
      }
    }
    assert_not_nil InsightAppSecConfig.find_by(name: new_name)
  end

  test 'authenticated staff superadmin only can destroy insight_app_sec_config' do
    sign_in users(:staffuser)
    delete insight_app_sec_config_path(InsightAppSecConfig.first)
    assert_response(302)
    sign_in users(:superadmin)
    delete insight_app_sec_config_path(InsightAppSecConfig.first)
    assert_equal flash[:notice], I18n.t('insight_app_sec_configs.notices.deletion_success')
  end

  test 'authenticated staff superadmin only can create new insight_app_sec_config' do
    sign_in users(:staffuser)
    new_name = 'dudu'
    params = {
      insight_app_sec_config:
      {
        name: new_name,
        url: 'url',
        api_key: 'test'
      }
    }
    post insight_app_sec_configs_path, params: params
    assert_nil InsightAppSecConfig.find_by(name: new_name)
    sign_in users(:superadmin)
    post insight_app_sec_configs_path, params: params
    assert_not_nil InsightAppSecConfig.find_by(name: new_name)
  end

  test 'authenticated staff superadmin cannot create new insight_app_sec_config without name' do
    sign_in users(:superadmin)
    insight_app_sec_configs_count = InsightAppSecConfig.count
    post insight_app_sec_configs_path, params:
    {
      insight_app_sec_config:
      {
        url: 'url',
        api_key: 'test'
      }
    }
    assert_equal insight_app_sec_configs_count, InsightAppSecConfig.count
  end

  test 'authenticated staff superadmin cannot create new insight_app_sec_config without api_key' do
    sign_in users(:superadmin)
    post insight_app_sec_configs_path, params:
    {
      insight_app_sec_config:
      {
        name: 'test',
        url: 'url'
      }
    }
    assert_nil InsightAppSecConfig.find_by(name: 'test')
  end

  test 'authenticated staff superadmin cannot create new insight_app_sec_config without url' do
    sign_in users(:superadmin)
    post insight_app_sec_configs_path, params:
    {
      insight_app_sec_config:
      {
        name: 'test',
        api_key: 'fregreg'
      }
    }
    assert_nil InsightAppSecConfig.find_by(name: 'test')
  end

  test 'authenticated staff superadmin cannot update insight_app_sec_config without name' do
    sign_in users(:superadmin)
    insight_app_sec_config = InsightAppSecConfig.first
    original_name = insight_app_sec_config.name
    original_api_key = insight_app_sec_config.api_key
    put insight_app_sec_config_path(insight_app_sec_config), params:
    {
      insight_app_sec_config:
      {
        name: nil,
        url: 'url',
        api_key: 'test'
      }
    }
    assert_equal original_api_key, InsightAppSecConfig.find_by(name: original_name).api_key
  end

  test 'authenticated staff superadmin cannot update insight_app_sec_config without url' do
    sign_in users(:superadmin)
    insight_app_sec_config = InsightAppSecConfig.first
    original_name = insight_app_sec_config.name
    original_api_key = insight_app_sec_config.api_key
    put insight_app_sec_config_path(insight_app_sec_config), params:
    {
      insight_app_sec_config:
      {
        name: 'nil',
        url: nil,
        api_key: 'test'
      }
    }
    assert_equal original_api_key, InsightAppSecConfig.find_by(name: original_name).api_key
  end

  test 'authenticated staff superadmin can update ias_config without changing api_key' do
    sign_in users(:superadmin)
    ias = InsightAppSecConfig.first
    new_name = 'update'
    put insight_app_sec_config_path(ias), params:
    {
      insight_app_sec_config:
      {
        name: new_name,
        url: 'url',
        api_key: nil
      }
    }
    assert_equal ias.api_key, InsightAppSecConfig.find_by(name: new_name).api_key
  end

  # Imports

  test 'unauthenticated cannot import scans' do
    post insight_app_sec_config_import_scans_path(InsightAppSecConfig.first)
    check_not_authenticated
  end

  test 'authenticated super_admin only can import scans' do
    sign_in users(:staffuser)
    post insight_app_sec_config_import_scans_path(InsightAppSecConfig.first)
    check_not_authorized
    sign_in users(:superadmin)
    post insight_app_sec_config_import_scans_path(InsightAppSecConfig.first)
    assert_equal flash[:notice], I18n.t('settings.import_scans')
  end

  test 'unauthenticated cannot update scans' do
    post insight_app_sec_config_update_scans_path(InsightAppSecConfig.first)
    check_not_authenticated
  end

  test 'authenticated super_admin only can update scans' do
    sign_in users(:staffuser)
    post insight_app_sec_config_update_scans_path(InsightAppSecConfig.first)
    check_not_authorized
    sign_in users(:superadmin)
    post insight_app_sec_config_update_scans_path(InsightAppSecConfig.first)
    assert_equal flash[:notice], I18n.t('settings.import_scans')
  end

  test 'authenticated super_admin only can delete recent existent wa scan' do
    sign_in users(:superadmin)
    params = {
      scan_id: WaScan.ias.find_by('launched_at > ?', Time.now.in_time_zone - 6.months).id.to_s
    }
    delete(insight_app_sec_config_delete_scan_path(insight_app_sec_configs(:ias_one)),
      params: params)
    assert_equal flash[:notice], I18n.t('settings.notices.deleted')
  end

  test 'authenticated super_admin cannot delete old existent wa scan' do
    sign_in users(:superadmin)
    params = {
      scan_id: WaScan.ias.find_by('launched_at < ?', Time.now.in_time_zone - 6.months).id.to_s
    }
    delete(insight_app_sec_config_delete_scan_path(insight_app_sec_configs(:ias_one)),
      params: params)
    assert_equal flash[:alert], I18n.t('settings.notices.wrong_value')
  end

  test 'authenticated super_admin cannot delete non existent wa scan' do
    sign_in users(:superadmin)
    delete insight_app_sec_config_delete_scan_path(insight_app_sec_configs(:ias_one)), params:
    {
      scan_id: 'ABC'
    }
    assert_equal flash[:alert], I18n.t('settings.notices.wrong_value')
  end

  test 'authenticated super_admin cannot delete scan without id' do
    sign_in users(:superadmin)
    delete insight_app_sec_config_delete_scan_path(insight_app_sec_configs(:ias_one))
    assert_equal flash[:alert], I18n.t('settings.notices.no_selection')
  end
end
