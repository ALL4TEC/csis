# frozen_string_literal: true

require 'test_helper'

class MicrosoftTeamsConfigsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'unauthenticated cannot list microsoft_teams_configs' do
    get microsoft_teams_configs_path
    check_not_authenticated
  end

  test 'authenticated super_admin only can list microsoft_teams_configs' do
    sign_in users(:staffuser)
    get microsoft_teams_configs_path
    check_not_authorized
    sign_in users(:superadmin)
    get microsoft_teams_configs_path
    assert_response 200
  end

  test 'unauthenticated cannot create microsoft teams config' do
    get new_microsoft_teams_config_path
    check_not_authenticated
  end

  test 'authenticated super_admin only can create microsoft teams config' do
    sign_in users(:staffuser)
    get new_microsoft_teams_config_path
    check_not_authorized
    user = users(:superadmin)
    sign_in user
    get new_microsoft_teams_config_path
    assert_response 200
    # GIVEN no microsoft_teams_config
    MicrosoftTeamsConfig.destroy_all
    assert MicrosoftTeamsConfig.count.zero?
    # WHEN sending new form data
    new_values = {
      new_channel_name: 'FDEHFOIUHZ',
      new_url: 'https://some_url.com',
      new_creator: user,
      new_users: []
    }
    post microsoft_teams_configs_path, params: { microsoft_teams_config: form_data(new_values) }
    # THEN a new microsoft teams config is created
    assert_equal 1, MicrosoftTeamsConfig.count
    new_microsoft_teams_config = MicrosoftTeamsConfig.first
    # WITH provided params
    check_model_saved_data(new_microsoft_teams_config, new_values)
    assert_redirected_to microsoft_teams_configs_path
  end

  test 'unauthenticated cannot edit microsoft teams config' do
    microsoft_teams_config = microsoft_teams_configs(:microsoft_teams_config_one)
    get edit_microsoft_teams_config_path(microsoft_teams_config)
    check_not_authenticated
  end

  test 'authenticated super_admin only can edit microsoft_teams_config' do
    microsoft_teams_config = microsoft_teams_configs(:microsoft_teams_config_one)
    sign_in users(:staffuser)
    get edit_microsoft_teams_config_path(microsoft_teams_config)
    check_not_authorized
    sign_in users(:superadmin)
    get edit_microsoft_teams_config_path(microsoft_teams_config)
    assert_response 200
  end

  test 'authenticated super_admin can update microsoft_teams_config' do
    user = users(:superadmin)
    sign_in user
    microsoft_teams_config = microsoft_teams_configs(:microsoft_teams_config_one)
    new_values = {
      new_channel_name: 'FDEHFOIUHZ',
      new_url: 'https://some_url.com',
      new_creator: user,
      new_users: []
    }
    assert_not_equal microsoft_teams_config.channel_name, new_values[:new_channel_name]
    put microsoft_teams_config_path(microsoft_teams_config), params: {
      microsoft_teams_config: form_data(new_values)
    }
    assert_redirected_to microsoft_teams_configs_path
    microsoft_teams_config.reload
    check_model_saved_data(microsoft_teams_config, new_values)
  end

  test 'unauthenticated cannot delete microsoft_teams_config' do
    microsoft_teams_config = microsoft_teams_configs(:microsoft_teams_config_one)
    delete microsoft_teams_config_path(microsoft_teams_config)
    check_not_authenticated
  end

  test 'authenticated super_admin only can delete microsoft_teams_config' do
    microsoft_teams_config = microsoft_teams_configs(:microsoft_teams_config_one)
    sign_in users(:staffuser)
    delete microsoft_teams_config_path(microsoft_teams_config)
    check_not_authorized
    sign_in users(:superadmin)
    delete microsoft_teams_config_path(microsoft_teams_config)
    assert_redirected_to microsoft_teams_configs_path
  end

  private

  # Assertions on mapper
  def check_model_saved_data(microsoft_teams_config, new_values)
    assert_equal microsoft_teams_config.name, new_values[:new_channel_name]
    assert_equal microsoft_teams_config.channel_name, new_values[:new_channel_name]
    assert_equal microsoft_teams_config.url, new_values[:new_url]
    assert_equal microsoft_teams_config.api_key, new_values[:new_url]
    assert_equal microsoft_teams_config.creator, new_values[:new_creator]
    assert_equal [], new_values[:new_users]
  end

  def form_data(new_values)
    {
      url: new_values[:new_url],
      channel_name: new_values[:new_channel_name],
      user_ids: new_values[:new_users]
    }
  end
end
