# frozen_string_literal: true

require 'test_helper'

class GoogleChatConfigsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'unauthenticated cannot list google_chat_configs' do
    get google_chat_configs_path
    check_not_authenticated
  end

  test 'authenticated super_admin only can list google_chat_configs' do
    sign_in users(:staffuser)
    get google_chat_configs_path
    check_not_authorized
    sign_in users(:superadmin)
    get google_chat_configs_path
    assert_response 200
  end

  test 'unauthenticated cannot create google chat config' do
    get new_google_chat_config_path
    check_not_authenticated
  end

  test 'authenticated super_admin only can create google chat config' do
    sign_in users(:staffuser)
    get new_google_chat_config_path
    check_not_authorized
    user = users(:superadmin)
    sign_in user
    get new_google_chat_config_path
    assert_response 200
    # GIVEN no google_chat_config
    GoogleChatConfig.destroy_all
    assert GoogleChatConfig.count.zero?
    # WHEN sending new form data
    new_values = {
      new_workspace_name: 'FDEHFOIUHZ',
      new_url: 'https://some_url.com',
      new_creator: user,
      new_users: []
    }
    post google_chat_configs_path, params: { google_chat_config: form_data(new_values) }
    # THEN a new google chat config is created
    assert_equal 1, GoogleChatConfig.count
    new_google_chat_config = GoogleChatConfig.first
    # WITH provided params
    check_model_saved_data(new_google_chat_config, new_values)
    assert_redirected_to google_chat_configs_path
  end

  test 'unauthenticated cannot edit google chat config' do
    google_chat_config = google_chat_configs(:google_chat_config_one)
    get edit_google_chat_config_path(google_chat_config)
    check_not_authenticated
  end

  test 'authenticated super_admin only can edit google_chat_config' do
    google_chat_config = google_chat_configs(:google_chat_config_one)
    sign_in users(:staffuser)
    get edit_google_chat_config_path(google_chat_config)
    check_not_authorized
    sign_in users(:superadmin)
    get edit_google_chat_config_path(google_chat_config)
    assert_response 200
  end

  test 'authenticated super_admin can update google_chat_config' do
    user = users(:superadmin)
    sign_in user
    google_chat_config = google_chat_configs(:google_chat_config_one)
    new_values = {
      new_workspace_name: 'FDEHFOIUHZ',
      new_url: 'https://some_url.com',
      new_creator: user,
      new_users: []
    }
    assert_not_equal google_chat_config.workspace_name, new_values[:new_workspace_name]
    put google_chat_config_path(google_chat_config), params: {
      google_chat_config: form_data(new_values)
    }
    assert_redirected_to google_chat_configs_path
    google_chat_config.reload
    check_model_saved_data(google_chat_config, new_values)
  end

  test 'unauthenticated cannot delete google_chat_config' do
    google_chat_config = google_chat_configs(:google_chat_config_one)
    delete google_chat_config_path(google_chat_config)
    check_not_authenticated
  end

  test 'authenticated super_admin only can delete google_chat_config' do
    google_chat_config = google_chat_configs(:google_chat_config_one)
    sign_in users(:staffuser)
    delete google_chat_config_path(google_chat_config)
    check_not_authorized
    sign_in users(:superadmin)
    delete google_chat_config_path(google_chat_config)
    assert_redirected_to google_chat_configs_path
  end

  private

  # Assertions on Mapper
  def check_model_saved_data(google_chat_config, new_values)
    assert_equal google_chat_config.name, new_values[:new_workspace_name]
    assert_equal google_chat_config.workspace_name, new_values[:new_workspace_name]
    assert_equal google_chat_config.url, new_values[:new_url]
    assert_equal google_chat_config.api_key, new_values[:new_url]
    assert_equal google_chat_config.creator, new_values[:new_creator]
    assert_equal [], new_values[:new_users]
  end

  def form_data(new_values)
    {
      workspace_name: new_values[:new_workspace_name],
      url: new_values[:new_url],
      user_ids: new_values[:new_users]
    }
  end
end
