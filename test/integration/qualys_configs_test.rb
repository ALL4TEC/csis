# frozen_string_literal: true

require 'test_helper'

class QualysConfigsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'unauthenticated cannot list qualys_configs' do
    get qualys_configs_path
    check_not_authenticated
  end

  test 'unauthenticated cannot create qualys_config' do
    post qualys_configs_path, params:
    {
      qualys_config:
      {
        name: 'test',
        login: 'test',
        password: 'test'
      }
    }
    check_not_authenticated
  end

  test 'Super Admin can list qualys_configs' do
    sign_in users(:superadmin)
    get qualys_configs_path
    assert_select 'main table.table' do
      QualysConfig.page(1).each do |qualys_config|
        assert_select 'td', text: qualys_config.name
      end
    end
  end

  test 'authenticated staff superadmin only can create qualys_config' do
    # GIVEN
    ScheduledJob.destroy_all
    assert ScheduledJob.all.count.zero?
    new_name = 'test'
    cron_vm = '1 1 1 1 1'
    cron_wa = '1 1 1 1 2'
    params = {
      qualys_config:
      {
        name: new_name,
        url: 'url',
        login: 'test',
        password: 'test',
        vm_import_cron: cron_vm,
        wa_import_cron: cron_wa,
        team_ids: [Team.first.id]
      }
    }
    # WHEN
    sign_in users(:staffuser)
    post qualys_configs_path, params: params
    # THEN
    assert_nil QualysConfig.find_by(name: new_name)
    # WHEN
    sign_in users(:superadmin)
    post qualys_configs_path, params: params
    # THEN
    qc = QualysConfig.find_by(name: new_name)
    assert_not_nil qc
    # Add check Resque.set_schedule called
    assert ScheduledJob.all.count.positive?
    assert_equal cron_vm, qc.vm_import_cron.value
    assert_equal cron_wa, qc.wa_import_cron.value
  end

  test 'authenticated staff superadmin can create qualys_config with empty import_crons' do
    # GIVEN
    new_name = 'test'
    params = {
      qualys_config:
      {
        name: new_name,
        url: 'url',
        login: 'test',
        password: 'test',
        vm_import_cron: '',
        wa_import_cron: '',
        team_ids: [Team.first.id]
      }
    }
    # WHEN
    sign_in users(:staffuser)
    post qualys_configs_path, params: params
    # THEN
    assert_nil QualysConfig.find_by(name: new_name)
    # WHEN
    sign_in users(:superadmin)
    post qualys_configs_path, params: params
    # THEN
    qc = QualysConfig.find_by(name: new_name)
    assert_not_nil qc
    # Add check Resque.remove_schedule called
    assert_empty qc.vm_import_cron.value
    assert_empty qc.wa_import_cron.value
  end

  test 'unauthenticated cannot view new qualys_config form' do
    get new_qualys_config_path
    check_not_authenticated
  end

  test 'unauthenticated cannot view edit qualys_config form' do
    get edit_qualys_config_path(QualysConfig.first)
    check_not_authenticated
  end

  test 'unauthenticated cannot view qualys_config infos' do
    get qualys_config_path(QualysConfig.first)
    check_not_authenticated
  end

  test 'unauthenticated cannot update qualys_config' do
    cron_vm = '1 1 1 1 1'
    cron_wa = '1 1 1 1 2'
    put qualys_config_path(QualysConfig.first), params:
    {
      qualys_config:
      {
        name: 'update',
        login: 'update',
        password: 'update',
        vm_import_cron: cron_vm,
        wa_import_cron: cron_wa,
        team_ids: [Team.first.id]
      }
    }
    check_not_authenticated
  end

  test 'unauthenticated cannot destroy qualys_config' do
    delete qualys_config_path(QualysConfig.first)
    check_not_authenticated
  end

  test 'authenticated staff superadmin only can view new qualys_config form' do
    sign_in users(:staffuser)
    get new_qualys_config_path
    assert_response(302)
    sign_in users(:superadmin)
    get new_qualys_config_path
    assert_response :success
  end

  test 'authenticated staff superadmin only can view edit qualys_config form' do
    sign_in users(:staffuser)
    get edit_qualys_config_path(QualysConfig.first)
    assert_response(302)
    sign_in users(:superadmin)
    get edit_qualys_config_path(QualysConfig.first)
    assert_response :success
  end

  test 'authenticated staff superadmin only can view qualys_config infos' do
    sign_in users(:staffuser)
    get qualys_config_path(QualysConfig.first)
    assert_response(302)
    sign_in users(:superadmin)
    get qualys_config_path(QualysConfig.first)
    assert_response :success
  end

  test 'authenticated staff superadmin only can update qualys_config' do
    sign_in users(:staffuser)
    new_name = 'update'
    cron_vm = '1 1 1 1 1'
    cron_wa = '1 1 1 1 2'
    params = {
      qualys_config:
      {
        name: new_name,
        login: 'update',
        password: 'update',
        vm_import_cron: cron_vm,
        wa_import_cron: cron_wa,
        team_ids: [Team.first.id]
      }
    }
    put qualys_config_path(QualysConfig.first), params: params
    assert_nil QualysConfig.find_by(name: new_name)
    sign_in users(:superadmin)
    put qualys_config_path(QualysConfig.first), params: params
    assert_not_nil QualysConfig.find_by(name: new_name)
  end

  test 'authenticated staff superadmin only can destroy qualys_config' do
    sign_in users(:staffuser)
    qc = qualys_configs(:qc_express)
    delete qualys_config_path(qc)
    check_unscoped
    qc = qualys_configs(:qc_one)
    delete qualys_config_path(qc)
    check_not_authorized
    sign_in users(:superadmin)
    delete qualys_config_path(qc)
    check_not_authorized # Has scans
    qc.wa_scans.delete_all
    qc.vm_scans.delete_all
    delete qualys_config_path(qc)
    assert_equal flash[:notice], I18n.t('qualys_configs.notices.deletion_success')
  end

  test 'superadmin can destroy qualys_config only if no scan present' do
    # GIVEN
    qc = qualys_configs(:qc_one)
    assert qc.any_scan?
    # WHEN
    sign_in users(:superadmin)
    delete qualys_config_path(qc)
    # THEN
    check_not_authorized
    # GIVEN
    qc = qualys_configs(:qc_express)
    assert_not qc.any_scan?
    # WHEN
    delete qualys_config_path(qc)
    # THEN
    assert_equal flash[:notice], I18n.t('qualys_configs.notices.deletion_success')
  end

  test 'authenticated staff superadmin only can create new qualys_config' do
    sign_in users(:staffuser)
    new_name = 'dudu'
    cron_vm = '1 1 1 1 1'
    cron_wa = '1 1 1 1 2'
    params = {
      qualys_config:
      {
        name: new_name,
        url: 'url',
        login: 'test',
        password: 'test',
        vm_import_cron: cron_vm,
        wa_import_cron: cron_wa
      }
    }
    post qualys_configs_path, params: params
    assert_nil QualysConfig.find_by(name: new_name)
    sign_in users(:superadmin)
    post qualys_configs_path, params: params
    assert_not_nil QualysConfig.find_by(name: new_name)
  end

  test 'authenticated staff superadmin cannot create new qualys_config without name' do
    sign_in users(:superadmin)
    qualys_configs_count = QualysConfig.count
    cron_vm = '1 1 1 1 1'
    cron_wa = '1 1 1 1 2'
    post qualys_configs_path, params:
    {
      qualys_config:
      {
        login: 'test',
        password: 'test',
        vm_import_cron: cron_vm,
        wa_import_cron: cron_wa
      }
    }
    assert_equal qualys_configs_count, QualysConfig.count
  end

  test 'authenticated staff superadmin cannot create new qualys_config without url' do
    sign_in users(:superadmin)
    qualys_configs_count = QualysConfig.count
    cron_vm = '1 1 1 1 1'
    cron_wa = '1 1 1 1 2'
    post qualys_configs_path, params:
    {
      qualys_config:
      {
        name: 'test',
        login: 'test',
        password: 'test',
        vm_import_cron: cron_vm,
        wa_import_cron: cron_wa
      }
    }
    assert_equal qualys_configs_count, QualysConfig.count
  end

  test 'authenticated staff superadmin cannot create new qualys_config without login' do
    sign_in users(:superadmin)
    cron_vm = '1 1 1 1 1'
    cron_wa = '1 1 1 1 2'
    post qualys_configs_path, params:
    {
      qualys_config:
      {
        name: 'test',
        url: 'url',
        password: 'test',
        vm_import_cron: cron_vm,
        wa_import_cron: cron_wa
      }
    }
    assert_nil QualysConfig.find_by(name: 'test')
  end

  test 'authenticated staff superadmin cannot create new qualys_config without password' do
    sign_in users(:staffuser)
    cron_vm = '1 1 1 1 1'
    cron_wa = '1 1 1 1 2'
    post qualys_configs_path, params:
    {
      qualys_config:
      {
        name: 'test',
        url: 'url',
        login: 'test',
        vm_import_cron: cron_vm,
        wa_import_cron: cron_wa
      }
    }
    assert_nil QualysConfig.find_by(name: 'test')
  end

  test 'authenticated staff superadmin cannot create new qualys_config without vm_import_cron' do
    sign_in users(:staffuser)
    cron_wa = '1 1 1 1 2'
    post qualys_configs_path, params:
    {
      qualys_config:
      {
        name: 'test',
        url: 'url',
        login: 'test',
        password: 'test',
        vm_import_cron: nil,
        wa_import_cron: cron_wa
      }
    }
    assert_nil QualysConfig.find_by(name: 'test')
  end

  test 'authenticated staff superadmin cannot create new qualys_config without wa_import_cron' do
    sign_in users(:staffuser)
    cron_vm = '1 1 1 1 1'
    post qualys_configs_path, params:
    {
      qualys_config:
      {
        name: 'test',
        url: 'url',
        login: 'test',
        password: 'test',
        vm_import_cron: cron_vm,
        wa_import_cron: nil
      }
    }
    assert_nil QualysConfig.find_by(name: 'test')
  end

  test 'authenticated staff superadmin cannot update qualys_config without name' do
    sign_in users(:superadmin)
    qualys_config = QualysConfig.first
    original_name = qualys_config.name
    original_login = qualys_config.login
    cron_vm = '1 1 1 1 1'
    cron_wa = '1 1 1 1 2'
    put qualys_config_path(qualys_config), params:
    {
      qualys_config:
      {
        name: nil,
        url: 'url',
        login: 'test',
        password: 'test',
        vm_import_cron: cron_vm,
        wa_import_cron: cron_wa
      }
    }
    assert_equal original_login, QualysConfig.find_by(name: original_name).login
  end

  test 'authenticated staff superadmin cannot update qualys_config without url' do
    sign_in users(:superadmin)
    qualys_config = QualysConfig.first
    original_name = qualys_config.name
    original_login = qualys_config.login
    cron_vm = '1 1 1 1 1'
    cron_wa = '1 1 1 1 2'
    put qualys_config_path(qualys_config), params:
    {
      qualys_config:
      {
        name: 'nil',
        url: nil,
        login: 'test',
        password: 'test',
        vm_import_cron: cron_vm,
        wa_import_cron: cron_wa
      }
    }
    assert_equal original_login, QualysConfig.find_by(name: original_name).login
  end

  test 'authenticated staff superadmin cannot update qualys_config without vm_import_cron' do
    sign_in users(:superadmin)
    qualys_config = QualysConfig.first
    original_name = qualys_config.name
    original_login = qualys_config.login
    cron_wa = '1 1 1 1 2'
    put qualys_config_path(qualys_config), params:
    {
      qualys_config:
      {
        name: 'nil',
        url: nil,
        login: 'test',
        password: 'test',
        vm_import_cron: nil,
        wa_import_cron: cron_wa
      }
    }
    assert_equal original_login, QualysConfig.find_by(name: original_name).login
  end

  test 'authenticated staff superadmin cannot update qualys_config without wa_import_cron' do
    sign_in users(:superadmin)
    qualys_config = QualysConfig.first
    original_name = qualys_config.name
    original_login = qualys_config.login
    cron_vm = '1 1 1 1 1'
    put qualys_config_path(qualys_config), params:
    {
      qualys_config:
      {
        name: 'nil',
        url: nil,
        login: 'test',
        password: 'test',
        vm_import_cron: cron_vm,
        wa_import_cron: nil
      }
    }
    assert_equal original_login, QualysConfig.find_by(name: original_name).login
  end

  test 'authenticated staff superadmin can update qualys_config without changing login' do
    sign_in users(:superadmin)
    qc = QualysConfig.first
    new_name = 'update'
    cron_vm = '1 1 1 1 1'
    cron_wa = '1 1 1 1 2'
    put qualys_config_path(qc), params:
    {
      qualys_config:
      {
        name: new_name,
        url: 'url',
        login: nil,
        password: 'update',
        vm_import_cron: cron_vm,
        wa_import_cron: cron_wa
      }
    }
    assert_equal qc.login, QualysConfig.find_by(name: new_name).login
  end

  test 'authenticated staff can update qualys_config without changing password' do
    sign_in users(:superadmin)
    qc = QualysConfig.first
    new_name = 'update'
    cron_vm = '1 1 1 1 1'
    cron_wa = '1 1 1 1 2'
    put qualys_config_path(qc), params:
    {
      qualys_config:
      {
        name: new_name,
        url: 'url',
        login: 'update',
        password: nil,
        vm_import_cron: cron_vm,
        wa_import_cron: cron_wa
      }
    }

    assert_equal qc.password, QualysConfig.find_by(name: new_name).password
  end

  # Imports

  test 'unauthenticated cannot import wa scans' do
    post qualys_config_import_scans_wa_path(QualysConfig.first)
    check_not_authenticated
  end

  test 'unauthenticated cannot import vm scans' do
    post qualys_config_import_scans_vm_path(QualysConfig.first)
    check_not_authenticated
  end

  test 'authenticated super_admin only can import vm scans' do
    sign_in users(:staffuser)
    post qualys_config_import_scans_vm_path(QualysConfig.first)
    check_not_authorized
    sign_in users(:superadmin)
    post qualys_config_import_scans_vm_path(QualysConfig.first), params:
    {
      qualys_config:
      {
        name: 'scan ref',
        qualys_vm_clients: ''
      }
    }
    assert_equal flash[:notice], I18n.t('settings.import_scans')
  end

  test 'authenticated super_admin only can import wa scans' do
    sign_in users(:staffuser)
    post qualys_config_import_scans_wa_path(QualysConfig.first)
    check_not_authorized
    sign_in users(:superadmin)
    post qualys_config_import_scans_wa_path(QualysConfig.first), params:
    {
      qualys_config:
      {
        name: 'scan name',
        qualys_wa_client_ids: []
      }
    }
    assert_equal flash[:notice], I18n.t('settings.import_scans')
  end

  test 'authenticated super_admin only can delete recent existing vm scan' do
    sign_in users(:staffuser)
    params = {
      scan_id: VmScan.where(scan_type: 'Type')
                     .find_by('launched_at > ?', Time.now.in_time_zone - 6.months).id.to_s
    }
    delete qualys_config_delete_scan_vm_path(qualys_configs(:qc_one)), params: params
    check_not_authorized
    sign_in users(:superadmin)
    delete qualys_config_delete_scan_vm_path(qualys_configs(:qc_one)), params: params
    assert_equal flash[:notice], I18n.t('settings.notices.deleted')
  end

  test 'authenticated super_admin cannot delete old existing vm scan' do
    sign_in users(:superadmin)
    params = {
      scan_id: VmScan.where(scan_type: 'Type')
                     .find_by('launched_at < ?', Time.now.in_time_zone - 6.months).id.to_s
    }
    delete qualys_config_delete_scan_vm_path(qualys_configs(:qc_one)), params: params
    assert_equal flash[:alert], I18n.t('settings.notices.wrong_value')
  end

  test 'authenticated super_admin only can delete recent existing wa scan' do
    sign_in users(:superadmin)
    params = {
      scan_id: WaScan.qualys.find_by('launched_at > ?', Time.now.in_time_zone - 6.months).id.to_s
    }
    delete qualys_config_delete_scan_wa_path(qualys_configs(:qc_one)), params: params
    assert_equal flash[:notice], I18n.t('settings.notices.deleted')
  end

  test 'authenticated super_admin cannot delete old existing wa scan' do
    sign_in users(:superadmin)
    params = {
      scan_id: WaScan.qualys.find_by('launched_at < ?', Time.now.in_time_zone - 6.months).id.to_s
    }
    delete qualys_config_delete_scan_wa_path(qualys_configs(:qc_one)), params: params
    assert_equal flash[:alert], I18n.t('settings.notices.wrong_value')
  end

  test 'authenticated super_admin cannot delete non existing vm scan' do
    sign_in users(:superadmin)
    delete qualys_config_delete_scan_vm_path(qualys_configs(:qc_one)), params:
    {
      scan_id: 'ABC'
    }
    assert_equal flash[:alert], I18n.t('settings.notices.wrong_value')
  end

  test 'authenticated super_admin cannot delete non existing wa scan' do
    sign_in users(:superadmin)
    delete qualys_config_delete_scan_wa_path(qualys_configs(:qc_one)), params:
    {
      scan_id: 'ABC'
    }
    assert_equal flash[:alert], I18n.t('settings.notices.wrong_value')
  end

  test 'authenticated super_admin cannot delete vm scan without id' do
    sign_in users(:superadmin)
    delete qualys_config_delete_scan_vm_path(qualys_configs(:qc_one))
    assert_equal flash[:alert], I18n.t('settings.notices.no_selection')
  end

  test 'unauthenticated cannot import vulnerabilities' do
    post qualys_config_import_vulnerabilities_path(QualysConfig.first)
    check_not_authenticated
  end

  test 'authenticated super_admin only can import vulnerabilities' do
    sign_in users(:staffuser)
    post qualys_config_import_vulnerabilities_path(QualysConfig.first)
    check_not_authorized
    sign_in users(:superadmin)
    post qualys_config_import_vulnerabilities_path(QualysConfig.first)
    assert_equal flash[:notice], I18n.t('settings.import_vulnerabilities')
  end

  test 'authenticated super_admin only can deactivate/activate account' do
    sign_in users(:staffuser)
    account = qualys_configs(:qc_one)
    assert AccountPredicate.active?(account)
    put activate_qualys_config_path(account)
    check_not_authorized # Not super_admin
    sign_in users(:superadmin)
    put activate_qualys_config_path(account)
    check_not_authorized # already active
    put deactivate_qualys_config_path(account)
    account.reload
    assert account.discarded?
    assert_redirected_to qualys_configs_path
    put activate_qualys_config_path(account)
    account.reload
    assert_not account.discarded?
    assert_redirected_to qualys_configs_path
  end
end
