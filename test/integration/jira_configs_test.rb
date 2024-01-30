# frozen_string_literal: true

require 'test_helper'

class JiraConfigsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'unauthenticated cannot list jira_configs' do
    get jira_configs_path
    check_not_authenticated
  end

  test 'unauthenticated cannot view new jira_config form' do
    get new_jira_config_path
    check_not_authenticated
  end

  test 'unauthenticated cannot view edit jira_config form' do
    get edit_jira_config_path(JiraConfig.first)
    check_not_authenticated
  end

  test 'unauthenticated cannot view jira_config infos' do
    get jira_config_path(JiraConfig.first)
    check_not_authenticated
  end

  test 'unauthenticated cannot create jira_configs' do
    post jira_configs_path, params:
    {
      jira_config:
      {
        name: 'create',
        url: 'https://create.example.com',
        context: '',
        project_id: 'PID',
        supplier_ids: [Client.first.id]
      }
    }
    check_not_authenticated
  end

  test 'unauthenticated cannot update jira_config' do
    put jira_config_path(JiraConfig.first), params:
    {
      jira_config:
      {
        name: 'update',
        url: 'https://update.example.com',
        context: '',
        project_id: 'PID',
        supplier_ids: [Client.first.id]
      }
    }
    check_not_authenticated
  end

  test 'unauthenticated cannot destroy jira_config' do
    delete jira_config_path(JiraConfig.first)
    check_not_authenticated
  end

  test 'authenticated staff superadmin only can list jira_config' do
    sign_in users(:staffuser)
    get jira_configs_path
    assert_response(302)
    sign_in users(:superadmin)
    get jira_configs_path
    assert_response :success
  end

  test 'authenticated staff superadmin only can create jira_config' do
    new_name = 'authenticated staff superadmin only can create'
    params = {
      jira_config:
      {
        name: new_name,
        url: 'https://create.example.com',
        context: '',
        project_id: 'PID',
        supplier_ids: [Client.first.id]
      }
    }
    # WHEN
    sign_in users(:staffuser)
    post jira_configs_path, params: params
    # THEN
    assert_nil JiraConfig.find_by(name: new_name)
    # WHEN
    sign_in users(:superadmin)
    post jira_configs_path, params: params
    # THEN
    assert I18n.t('jira_configs.access_error').in?(response.body)
  end

  test 'authenticated staff superadmin only can view new jira_config form' do
    sign_in users(:staffuser)
    get new_jira_config_path
    assert_response(302)
    sign_in users(:superadmin)
    get new_jira_config_path
    assert_response :success
  end

  test 'authenticated staff superadmin only can view edit jira_config form' do
    sign_in users(:staffuser)
    get edit_jira_config_path(JiraConfig.first)
    assert_response(302)
    sign_in users(:superadmin)
    get edit_jira_config_path(JiraConfig.first)
    assert_response :success
  end

  test 'authenticated staff superadmin only can view jira_config infos' do
    sign_in users(:staffuser)
    get jira_config_path(JiraConfig.first)
    assert_response(302)
    sign_in users(:superadmin)
    get jira_config_path(JiraConfig.first)
    assert_response :success
  end

  test 'authenticated staff superadmin only can update jira_config' do
    sign_in users(:staffuser)
    new_name = 'authenticated staff superadmin only can update'
    params = {
      jira_config:
      {
        name: new_name,
        url: 'https://update.example.com',
        context: '',
        project_id: 'PID',
        supplier_ids: [Client.first.id]
      }
    }
    put jira_config_path(JiraConfig.first), params: params
    assert_nil JiraConfig.find_by(name: new_name)
    sign_in users(:superadmin)
    put jira_config_path(JiraConfig.first), params: params
    assert_not_nil JiraConfig.find_by(name: new_name)
  end

  test 'authenticated staff superadmin only can destroy jira_config' do
    sign_in users(:staffuser)
    jc = jira_configs(:jc_two) # jc_one has Issue and won't be deleted
    delete jira_config_path(jc)
    check_unscoped
    sign_in users(:superadmin)
    delete jira_config_path(jc)
    assert_equal flash[:notice], I18n.t('jira_configs.notices.deletion_success')
  end

  test 'authenticated staff superadmin can destroy jira_config only if not used by issue' do
    sign_in users(:superadmin)
    jc = jira_configs(:jc_one)
    delete jira_config_path(jc)
    check_not_authorized
    jc = jira_configs(:jc_two)
    delete jira_config_path(jc)
    assert_equal flash[:notice], I18n.t('jira_configs.notices.deletion_success')
  end

  test 'authenticated staff superadmin cannot create jira_config without name' do
    jira_configs_count = JiraConfig.count
    params = {
      jira_config:
      {
        url: 'https://create.example.com',
        context: '',
        project_id: 'PID',
        supplier_ids: [Client.first.id]
      }
    }
    sign_in users(:superadmin)
    post jira_configs_path, params: params
    assert_equal(jira_configs_count, JiraConfig.count)
  end

  test 'authenticated staff superadmin cannot create jira_config without url' do
    jira_configs_count = JiraConfig.count
    params = {
      jira_config:
      {
        name: 'create',
        context: '',
        project_id: 'PID',
        supplier_ids: [Client.first.id]
      }
    }
    sign_in users(:superadmin)
    post jira_configs_path, params: params
    assert_equal(jira_configs_count, JiraConfig.count)
  end

  test 'authenticated staff superadmin cannot create jira_config without context' do
    jira_configs_count = JiraConfig.count
    params = {
      jira_config:
      {
        name: 'create',
        url: 'https://create.example.com',
        project_id: 'PID',
        supplier_ids: [Client.first.id]
      }
    }
    sign_in users(:superadmin)
    post jira_configs_path, params: params
    assert_equal(jira_configs_count, JiraConfig.count)
  end

  test 'authenticated staff superadmin cannot create jira_config without project_id' do
    jira_configs_count = JiraConfig.count
    params = {
      jira_config:
      {
        name: 'create',
        url: 'https://create.example.com',
        context: '',
        supplier_ids: [Client.first.id]
      }
    }
    sign_in users(:superadmin)
    post jira_configs_path, params: params
    assert_equal(jira_configs_count, JiraConfig.count)
  end

  test 'authenticated staff superadmin cannot update jira_config without name' do
    sign_in users(:superadmin)
    jira_config = JiraConfig.first
    original_name = jira_config.name
    params = {
      jira_config:
      {
        name: nil,
        url: 'https://update.example.com',
        context: '',
        project_id: 'PID',
        supplier_ids: [Client.first.id]
      }
    }
    put jira_config_path(jira_config), params: params
    assert_equal jira_config, JiraConfig.find_by(name: original_name)
  end

  test 'authenticated staff superadmin cannot update jira_config without url' do
    sign_in users(:superadmin)
    jira_config = JiraConfig.first
    new_name = "#{jira_config}-update"
    original_name = jira_config.name
    params = {
      jira_config:
      {
        name: new_name,
        url: nil,
        context: '',
        project_id: 'PID',
        supplier_ids: [Client.first.id]
      }
    }
    put jira_config_path(jira_config), params: params
    assert_equal jira_config, JiraConfig.find_by(name: original_name)
  end

  test 'authenticated staff superadmin cannot update jira_config without context' do
    sign_in users(:superadmin)
    jira_config = JiraConfig.first
    new_name = "#{jira_config}-update"
    params = {
      jira_config:
      {
        name: new_name,
        url: 'https://update.example.com',
        context: nil,
        project_id: 'PID',
        supplier_ids: [Client.first.id]
      }
    }
    assert_raises ActiveRecord::NotNullViolation do
      put jira_config_path(jira_config), params: params
    end
  end

  test 'authenticated staff superadmin cannot update jira_config without project_id' do
    sign_in users(:superadmin)
    jira_config = JiraConfig.first
    new_name = "#{jira_config}-update"
    original_name = jira_config.name
    params = {
      jira_config:
      {
        name: new_name,
        url: 'https://update.example.com',
        context: '',
        project_id: nil,
        supplier_ids: [Client.first.id]
      }
    }
    put jira_config_path(jira_config), params: params
    assert_equal jira_config, JiraConfig.find_by(name: original_name)
  end
end
