# frozen_string_literal: true

require 'test_helper'

class CyberwatchConfigsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'unauthenticated cannot list cyberwatch_configs' do
    get cyberwatch_configs_path
    check_not_authenticated
  end

  test 'unauthenticated cannot create cyberwatch_config' do
    post cyberwatch_configs_path, params:
    {
      cyberwatch_config:
      {
        name: 'test',
        api_key: 'test',
        secret_key: 'test'
      }
    }
    check_not_authenticated
  end

  test 'Super Admin can list cyberwatch_configs' do
    sign_in users(:superadmin)
    get cyberwatch_configs_path
    assert_select 'main table.table' do
      CyberwatchConfig.page(1).each do |cyberwatch_config|
        assert_select 'td', text: cyberwatch_config.name
      end
    end
  end

  test 'authenticated staff superadmin only can create cyberwatch_config' do
    # GIVEN
    ScheduledJob.destroy_all
    assert ScheduledJob.all.count.zero?
    new_name = 'test'
    cron_vm = '1 1 1 1 1'
    params = {
      cyberwatch_config:
      {
        name: new_name,
        url: 'url',
        verify_ssl_certificate: true,
        api_key: 'test',
        secret_key: 'test',
        vm_import_cron: cron_vm,
        team_ids: [Team.first.id]
      }
    }
    # WHEN
    sign_in users(:staffuser)
    post cyberwatch_configs_path, params: params
    # THEN
    assert_nil CyberwatchConfig.find_by(name: new_name)
    # WHEN
    sign_in users(:superadmin)
    post cyberwatch_configs_path, params: params
    # THEN
    cc = CyberwatchConfig.find_by(name: new_name)
    assert_not_nil cc
    # Add check Resque.set_schedule called
    assert ScheduledJob.all.count.positive?
    assert_equal cron_vm, cc.vm_import_cron.value
  end

  test 'authenticated staff superadmin can create cyberwatch_config with empty import_crons' do
    # GIVEN
    new_name = 'test'
    params = {
      cyberwatch_config:
      {
        name: new_name,
        url: 'url',
        verify_ssl_certificate: true,
        api_key: 'test',
        secret_key: 'test',
        vm_import_cron: '',
        team_ids: [Team.first.id]
      }
    }
    # WHEN
    sign_in users(:staffuser)
    post cyberwatch_configs_path, params: params
    # THEN
    assert_nil CyberwatchConfig.find_by(name: new_name)
    # WHEN
    sign_in users(:superadmin)
    post cyberwatch_configs_path, params: params
    # THEN
    cc = CyberwatchConfig.find_by(name: new_name)
    assert_not_nil cc
    # Add check Resque.remove_schedule called
    assert_empty cc.vm_import_cron.value
  end

  test 'unauthenticated cannot view new cyberwatch_config form' do
    get new_cyberwatch_config_path
    check_not_authenticated
  end

  test 'unauthenticated cannot view edit cyberwatch_config form' do
    get edit_cyberwatch_config_path(CyberwatchConfig.first)
    check_not_authenticated
  end

  test 'unauthenticated cannot view cyberwatch_config infos' do
    get cyberwatch_config_path(CyberwatchConfig.first)
    check_not_authenticated
  end

  test 'unauthenticated cannot update cyberwatch_config' do
    cron_vm = '1 1 1 1 1'
    put cyberwatch_config_path(CyberwatchConfig.first), params:
    {
      cyberwatch_config:
      {
        name: 'update',
        verify_ssl_certificate: true,
        api_key: 'update',
        secret_key: 'update',
        vm_import_cron: cron_vm,
        team_ids: [Team.first.id]
      }
    }
    check_not_authenticated
  end

  test 'unauthenticated cannot destroy cyberwatch_config' do
    delete cyberwatch_config_path(CyberwatchConfig.first)
    check_not_authenticated
  end

  test 'authenticated staff superadmin only can view new cyberwatch_config form' do
    sign_in users(:staffuser)
    get new_cyberwatch_config_path
    assert_response(302)
    sign_in users(:superadmin)
    get new_cyberwatch_config_path
    assert_response :success
  end

  test 'authenticated staff superadmin only can view edit cyberwatch_config form' do
    sign_in users(:staffuser)
    get edit_cyberwatch_config_path(CyberwatchConfig.first)
    assert_response(302)
    sign_in users(:superadmin)
    get edit_cyberwatch_config_path(CyberwatchConfig.first)
    assert_response :success
  end

  test 'authenticated staff superadmin only can view cyberwatch_config infos' do
    sign_in users(:staffuser)
    get cyberwatch_config_path(CyberwatchConfig.first)
    assert_response(302)
    sign_in users(:superadmin)
    get cyberwatch_config_path(CyberwatchConfig.first)
    assert_response :success
  end

  test 'authenticated staff superadmin only can update cyberwatch_config' do
    sign_in users(:staffuser)
    new_name = 'update'
    cron_vm = '1 1 1 1 1'
    params = {
      cyberwatch_config:
      {
        name: new_name,
        api_key: 'update',
        secret_key: 'update',
        vm_import_cron: cron_vm,
        team_ids: [Team.first.id]
      }
    }
    put cyberwatch_config_path(CyberwatchConfig.first), params: params
    assert_nil CyberwatchConfig.find_by(name: new_name)
    sign_in users(:superadmin)
    put cyberwatch_config_path(CyberwatchConfig.first), params: params
    assert_not_nil CyberwatchConfig.find_by(name: new_name)
  end

  test 'authenticated staff superadmin only can destroy cyberwatch_config' do
    sign_in users(:staffuser)
    cc = cyberwatch_configs(:cbw_two)
    delete cyberwatch_config_path(cc)
    check_not_authorized
    sign_in users(:superadmin)
    delete cyberwatch_config_path(cc)
    assert_equal flash[:notice], I18n.t('cyberwatch_configs.notices.deletion_success')
  end

  test 'superadmin can destroy cyberwatch_config only if no scan present' do
    # GIVEN
    cc = cyberwatch_configs(:cbw_one)
    assert cc.any_scan?
    # WHEN
    sign_in users(:superadmin)
    delete cyberwatch_config_path(cc)
    # THEN
    check_not_authorized
    # GIVEN
    cc = cyberwatch_configs(:cbw_two)
    assert_not cc.any_scan?
    # WHEN
    delete cyberwatch_config_path(cc)
    # THEN
    assert_equal flash[:notice], I18n.t('cyberwatch_configs.notices.deletion_success')
  end

  test 'authenticated staff superadmin only can create new cyberwatch_config' do
    sign_in users(:staffuser)
    new_name = 'dudu'
    cron_vm = '1 1 1 1 1'
    params = {
      cyberwatch_config:
      {
        name: new_name,
        url: 'url',
        verify_ssl_certificate: true,
        api_key: 'test',
        secret_key: 'test',
        vm_import_cron: cron_vm
      }
    }
    post cyberwatch_configs_path, params: params
    assert_nil CyberwatchConfig.find_by(name: new_name)
    sign_in users(:superadmin)
    post cyberwatch_configs_path, params: params
    assert_not_nil CyberwatchConfig.find_by(name: new_name)
  end

  test 'authenticated staff superadmin cannot create new cyberwatch_config without name' do
    sign_in users(:superadmin)
    cyberwatch_configs_count = CyberwatchConfig.count
    cron_vm = '1 1 1 1 1'
    post cyberwatch_configs_path, params:
    {
      cyberwatch_config:
      {
        api_key: 'test',
        secret_key: 'test',
        vm_import_cron: cron_vm
      }
    }
    assert_equal cyberwatch_configs_count, CyberwatchConfig.count
  end

  test 'authenticated staff superadmin cannot create new cyberwatch_config without url' do
    sign_in users(:superadmin)
    cyberwatch_configs_count = CyberwatchConfig.count
    cron_vm = '1 1 1 1 1'
    post cyberwatch_configs_path, params:
    {
      cyberwatch_config:
      {
        name: 'test',
        api_key: 'test',
        secret_key: 'test',
        vm_import_cron: cron_vm
      }
    }
    assert_equal cyberwatch_configs_count, CyberwatchConfig.count
  end

  test 'authenticated staff superadmin cannot create new cyberwatch_config without api_key' do
    sign_in users(:superadmin)
    cron_vm = '1 1 1 1 1'
    post cyberwatch_configs_path, params:
    {
      cyberwatch_config:
      {
        name: 'test',
        url: 'url',
        secret_key: 'test',
        vm_import_cron: cron_vm
      }
    }
    assert_nil CyberwatchConfig.find_by(name: 'test')
  end

  test 'authenticated staff superadmin cannot create new cyberwatch_config without secret_key' do
    sign_in users(:staffuser)
    cron_vm = '1 1 1 1 1'
    post cyberwatch_configs_path, params:
    {
      cyberwatch_config:
      {
        name: 'test',
        url: 'url',
        api_key: 'test',
        vm_import_cron: cron_vm
      }
    }
    assert_nil CyberwatchConfig.find_by(name: 'test')
  end

  test 'authenticated superadmin cannot create new cyberwatch_config without vm_import_cron' do
    sign_in users(:staffuser)
    post cyberwatch_configs_path, params:
    {
      cyberwatch_config:
      {
        name: 'test',
        url: 'url',
        api_key: 'test',
        secret_key: 'test',
        vm_import_cron: nil
      }
    }
    assert_nil CyberwatchConfig.find_by(name: 'test')
  end

  test 'authenticated staff superadmin cannot update cyberwatch_config without name' do
    sign_in users(:superadmin)
    cyberwatch_config = CyberwatchConfig.first
    original_name = cyberwatch_config.name
    original_login = cyberwatch_config.api_key
    cron_vm = '1 1 1 1 1'
    put cyberwatch_config_path(cyberwatch_config), params:
    {
      cyberwatch_config:
      {
        name: nil,
        url: 'url',
        api_key: 'test',
        secret_key: 'test',
        vm_import_cron: cron_vm
      }
    }
    assert_equal original_login, CyberwatchConfig.find_by(name: original_name).api_key
  end

  test 'authenticated staff superadmin cannot update cyberwatch_config without url' do
    sign_in users(:superadmin)
    cyberwatch_config = CyberwatchConfig.first
    original_name = cyberwatch_config.name
    original_login = cyberwatch_config.api_key
    cron_vm = '1 1 1 1 1'
    put cyberwatch_config_path(cyberwatch_config), params:
    {
      cyberwatch_config:
      {
        name: 'nil',
        url: nil,
        api_key: 'test',
        secret_key: 'test',
        vm_import_cron: cron_vm
      }
    }
    assert_equal original_login, CyberwatchConfig.find_by(name: original_name).api_key
  end

  test 'authenticated staff superadmin cannot update cyberwatch_config without vm_import_cron' do
    sign_in users(:superadmin)
    cyberwatch_config = CyberwatchConfig.first
    original_name = cyberwatch_config.name
    original_login = cyberwatch_config.api_key
    put cyberwatch_config_path(cyberwatch_config), params:
    {
      cyberwatch_config:
      {
        name: 'nil',
        url: nil,
        api_key: 'test',
        secret_key: 'test',
        vm_import_cron: nil
      }
    }
    assert_equal original_login, CyberwatchConfig.find_by(name: original_name).api_key
  end

  test 'authenticated staff superadmin can update cyberwatch_config without changing api_key' do
    sign_in users(:superadmin)
    cc = CyberwatchConfig.first
    new_name = 'update'
    cron_vm = '1 1 1 1 1'
    put cyberwatch_config_path(cc), params:
    {
      cyberwatch_config:
      {
        name: new_name,
        url: 'url',
        secret_key: 'update',
        vm_import_cron: cron_vm
      }
    }
    assert_equal cc.api_key, CyberwatchConfig.find_by(name: new_name).api_key
  end

  test 'authenticated staff can update cyberwatch_config without changing secret_key' do
    sign_in users(:superadmin)
    cc = CyberwatchConfig.first
    new_name = 'update'
    cron_vm = '1 1 1 1 1'
    put cyberwatch_config_path(cc), params:
    {
      cyberwatch_config:
      {
        name: new_name,
        url: 'url',
        api_key: 'update',
        secret_key: nil,
        vm_import_cron: cron_vm
      }
    }

    assert_equal cc.secret_key, CyberwatchConfig.find_by(name: new_name).secret_key
  end

  # Imports

  test 'unauthenticated cannot import scans' do
    post cyberwatch_config_import_scans_path(CyberwatchConfig.first)
    check_not_authenticated
  end

  test 'authenticated super_admin only can import scans' do
    sign_in users(:staffuser)
    post cyberwatch_config_import_scans_path(CyberwatchConfig.first)
    check_not_authorized
    sign_in users(:superadmin)
    post cyberwatch_config_import_scans_path(CyberwatchConfig.first), params:
    {
      cyberwatch_config:
      {
        name: 'scan ref'
      }
    }
    assert_equal flash[:notice], I18n.t('settings.import_scans')
  end

  test 'authenticated super_admin only can delete recent existent scan' do
    sign_in users(:staffuser)
    params = {
      scan_id: VmScan.where(scan_type: 'Cyberwatch')
                     .find_by('launched_at > ?', Time.now.in_time_zone - 6.months).id.to_s
    }
    delete cyberwatch_config_delete_scan_path(cyberwatch_configs(:cbw_one)), params: params
    check_not_authorized
    sign_in users(:superadmin)
    delete cyberwatch_config_delete_scan_path(cyberwatch_configs(:cbw_one)), params: params
    assert_equal flash[:notice], I18n.t('settings.notices.deleted')
  end

  test 'authenticated super_admin cannot delete old existent scan' do
    sign_in users(:superadmin)
    params = {
      scan_id: VmScan.where(scan_type: 'Cyberwatch')
                     .find_by('launched_at < ?', Time.now.in_time_zone - 6.months).id.to_s
    }
    delete cyberwatch_config_delete_scan_path(cyberwatch_configs(:cbw_one)), params: params
    assert_equal flash[:alert], I18n.t('settings.notices.wrong_value')
  end

  test 'authenticated super_admin cannot delete non existent scan' do
    sign_in users(:superadmin)
    delete cyberwatch_config_delete_scan_path(cyberwatch_configs(:cbw_one)), params:
    {
      scan_id: 'ABC'
    }
    assert_equal flash[:alert], I18n.t('settings.notices.wrong_value')
  end

  test 'authenticated super_admin cannot delete scan without id' do
    sign_in users(:superadmin)
    delete cyberwatch_config_delete_scan_path(cyberwatch_configs(:cbw_one))
    assert_equal flash[:alert], I18n.t('settings.notices.no_selection')
  end

  test 'unauthenticated cannot import vulnerabilities' do
    post cyberwatch_config_import_vulnerabilities_path(CyberwatchConfig.first)
    check_not_authenticated
  end

  test 'authenticated super_admin only can import vulnerabilities' do
    sign_in users(:staffuser)
    post cyberwatch_config_import_vulnerabilities_path(CyberwatchConfig.first)
    check_not_authorized
    sign_in users(:superadmin)
    post cyberwatch_config_import_vulnerabilities_path(CyberwatchConfig.first)
    assert_equal flash[:notice], I18n.t('settings.import_vulnerabilities')
  end

  test 'authenticated super_admin only can deactivate/activate account' do
    sign_in users(:staffuser)
    account = CyberwatchConfig.first
    assert AccountPredicate.active?(account)
    put activate_cyberwatch_config_path(account)
    check_not_authorized # Not super_admin
    sign_in users(:superadmin)
    put activate_cyberwatch_config_path(account)
    check_not_authorized # already active
    put deactivate_cyberwatch_config_path(account)
    account.reload
    assert account.discarded?
    assert_redirected_to cyberwatch_configs_path
    put activate_cyberwatch_config_path(account)
    account.reload
    assert_not account.discarded?
    assert_redirected_to cyberwatch_configs_path
  end
end
