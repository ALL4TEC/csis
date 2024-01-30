# frozen_string_literal: true

require 'test_helper'

class IdpConfigsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'unauthenticated cannot list idp_configs' do
    get idp_configs_path
    check_not_authenticated
  end

  test 'unauthenticated cannot create idp_config' do
    post idp_configs_path, params:
    {
      idp_config:
      {
        name: 'test',
        idp_metadata_url: 'url',
        idp_entity_id: 'id'
      }
    }
    check_not_authenticated
  end

  test 'Super Admin can list idp_configs' do
    sign_in users(:superadmin)
    get idp_configs_path
    assert_select 'main table.table' do
      IdpConfig.page(1).each do |idp_config|
        assert_select 'td', text: idp_config.name
      end
    end
  end

  test 'unauthenticated cannot view new idp_config form' do
    get new_idp_config_path
    check_not_authenticated
  end

  test 'unauthenticated cannot view edit idp_config form' do
    get edit_idp_config_path(IdpConfig.first)
    check_not_authenticated
  end

  test 'unauthenticated cannot view idp_config infos' do
    get idp_config_path(IdpConfig.first)
    check_not_authenticated
  end

  test 'unauthenticated cannot update idp_config' do
    put idp_config_path(IdpConfig.first), params:
    {
      idp_config:
      {
        name: 'update',
        idp_metadata_url: 'url',
        idp_entity_id: 'id'
      }
    }
    check_not_authenticated
  end

  test 'unauthenticated cannot destroy idp_config' do
    delete idp_config_path(IdpConfig.first)
    check_not_authenticated
  end

  test 'unauthenticated cannot activate idp_config' do
    c = IdpConfig.find_by(active: false)
    put activate_idp_config_path(c.id), params: {}
    check_not_authenticated
  end

  test 'unauthenticated cannot deactivate idp_config' do
    c = IdpConfig.find_by(active: true)
    put deactivate_idp_config_path(c.id), params: {}
    check_not_authenticated
  end

  test 'authenticated staff superadmin only can view new idp_config form' do
    sign_in users(:staffuser)
    get new_idp_config_path
    assert_response(302)
    sign_in users(:superadmin)
    get new_idp_config_path
    assert_response :success
  end

  test 'authenticated staff superadmin only can view edit idp_config form' do
    sign_in users(:staffuser)
    get edit_idp_config_path(IdpConfig.first)
    assert_response(302)
    sign_in users(:superadmin)
    get edit_idp_config_path(IdpConfig.first)
    assert_response :success
  end

  test 'authenticated staff superadmin only can view idp_config infos' do
    sign_in users(:staffuser)
    get idp_config_path(IdpConfig.first)
    assert_response(302)
    sign_in users(:superadmin)
    get idp_config_path(IdpConfig.first)
    assert_response :success
  end

  test 'authenticated staff superadmin only can update idp_config' do
    sign_in users(:staffuser)
    new_name = 'update'
    put idp_config_path(IdpConfig.first), params:
    {
      idp_config:
      {
        name: new_name,
        idp_metadata_url: 'url',
        idp_entity_id: 'id'
      }
    }
    assert_nil IdpConfig.find_by(name: new_name)
    sign_in users(:superadmin)
    put idp_config_path(IdpConfig.first), params:
    {
      idp_config:
      {
        name: new_name,
        idp_metadata_url: 'url',
        idp_entity_id: 'id'
      }
    }
    assert_not_nil IdpConfig.find_by(name: new_name)
  end

  test 'authenticated staff superadmin only can destroy idp_config' do
    sign_in users(:staffuser)
    delete idp_config_path(IdpConfig.first)
    assert_response(302)

    sign_in users(:superadmin)
    delete idp_config_path(IdpConfig.first)
    assert_equal flash[:notice], I18n.t('idp_configs.notices.deletion_success')
  end

  test 'authenticated staff superadmin only can activate idp_config' do
    sign_in users(:staffuser)
    c = IdpConfig.find_by(active: false)
    put activate_idp_config_path(c.id), params: {}
    assert_response(302)

    sign_in users(:superadmin)
    c = IdpConfig.find_by(active: false)
    put activate_idp_config_path(c.id), params: {}
    assert_equal flash[:notice], I18n.t('idp_configs.notices.activated')
  end

  test 'authenticated staff superadmin only can deactivate idp_config' do
    sign_in users(:staffuser)
    c = IdpConfig.find_by(active: true)
    put deactivate_idp_config_path(c.id), params: {}
    assert_response(302)

    sign_in users(:superadmin)
    c = IdpConfig.find_by(active: true)
    put deactivate_idp_config_path(c.id), params: {}
    assert_equal flash[:notice], I18n.t('idp_configs.notices.deactivated')
  end

  test 'authenticated staff superadmin only can create new idp_config' do
    sign_in users(:staffuser)
    new_name = 'dudu'
    params = {
      idp_config:
      {
        name: new_name,
        idp_metadata_url: 'url',
        idp_entity_id: 'id'
      }
    }
    post idp_configs_path, params: params
    assert_nil IdpConfig.find_by(name: new_name)
    sign_in users(:superadmin)
    post idp_configs_path, params: params
    assert_not_nil IdpConfig.find_by(name: new_name)
  end

  test 'authenticated staff superadmin cannot create new idp_config without name' do
    sign_in users(:superadmin)
    idp_configs_count = IdpConfig.count
    post idp_configs_path, params:
    {
      idp_config:
      {
        idp_metadata_url: 'url',
        idp_entity_id: 'id'
      }
    }
    assert_equal idp_configs_count, IdpConfig.count
  end

  test 'authenticated staff superadmin cannot create new idp_config w/o idp_metadata_(url&xml)' do
    sign_in users(:superadmin)
    post idp_configs_path, params:
    {
      idp_config:
      {
        name: 'test',
        idp_entity_id: 'id'
      }
    }
    assert_nil IdpConfig.find_by(name: 'test')
  end

  test 'authenticated staff superadmin can create new idp_config w/ idp_metadata_xml' do
    sign_in users(:staffuser)
    new_name = 'dudu'
    params = {
      idp_config:
      {
        name: new_name,
        idp_metadata_xml: fixture_file_upload('idp_metadata.xml'),
        idp_entity_id: 'id'
      }
    }
    post idp_configs_path, params: params
    assert_nil IdpConfig.find_by(name: new_name)
    sign_in users(:superadmin)
    post idp_configs_path, params: params
    assert_not_nil IdpConfig.find_by(name: new_name)
  end

  test 'authenticated staff superadmin cannot update idp_config without name' do
    sign_in users(:superadmin)
    idp_config = IdpConfig.first
    original_name = idp_config.name
    put idp_config_path(idp_config), params:
    {
      idp_config:
      {
        name: nil,
        idp_metadata_url: 'url',
        idp_entity_id: 'id'
      }
    }
    assert IdpConfig.find_by(name: original_name).present?
  end

  test 'authenticated staff superadmin cannot update idp_config w/o idp_metadata_(url&xml)' do
    sign_in users(:superadmin)
    idp_config = IdpConfig.first
    new_name = 'test'
    put idp_config_path(idp_config), params:
    {
      idp_config:
      {
        name: new_name,
        idp_metadata_url: nil,
        idp_entity_id: 'id'
      }
    }
    assert IdpConfig.find_by(name: new_name).blank?
  end

  test 'authenticated staff superadmin can update idp_config w/ idp_metadata_xml' do
    sign_in users(:superadmin)
    idp_config = IdpConfig.first
    new_name = 'test'
    put idp_config_path(idp_config), params:
    {
      idp_config:
      {
        name: new_name,
        idp_metadata_xml: fixture_file_upload('idp_metadata.xml'),
        idp_entity_id: 'id'
      }
    }
    assert IdpConfig.find_by(name: new_name).present?
  end
end
