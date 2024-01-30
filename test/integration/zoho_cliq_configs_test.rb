# frozen_string_literal: true

require 'test_helper'

class ZohoCliqConfigsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'unauthenticated cannot list zoho_cliq_configs' do
    get zoho_cliq_configs_path
    check_not_authenticated
  end

  test 'authenticated super_admin only can list zoho_cliq_configs' do
    sign_in users(:staffuser)
    get zoho_cliq_configs_path
    check_not_authorized
    sign_in users(:superadmin)
    get zoho_cliq_configs_path
    assert_response 200
  end

  test 'unauthenticated cannot create zoho cliq config' do
    get new_zoho_cliq_config_path
    check_not_authenticated
  end

  test 'authenticated super_admin only can create zoho cliq config' do
    sign_in users(:staffuser)
    get new_zoho_cliq_config_path
    check_not_authorized
    user = users(:superadmin)
    sign_in user
    get new_zoho_cliq_config_path
    assert_response 200
    # GIVEN no zoho_cliq_config
    ZohoCliqConfig.destroy_all
    assert ZohoCliqConfig.count.zero?
    # WHEN sending new form data
    new_values = {
      new_bot_name: 'FDEHFOIUHZ',
      new_webhook_domain: 'https://some_webhook_domain.com',
      new_zapikey: 'dszpofizeofhnzeohf',
      new_creator: user,
      new_users: []
    }
    post zoho_cliq_configs_path, params: { zoho_cliq_config: form_data(new_values) }
    # THEN a new zoho cliq config is created
    assert_equal 1, ZohoCliqConfig.count
    new_zoho_cliq_config = ZohoCliqConfig.first
    # WITH provided params
    check_model_saved_data(new_zoho_cliq_config, new_values)
    assert_redirected_to zoho_cliq_configs_path
  end

  test 'unauthenticated cannot edit zoho cliq config' do
    zoho_cliq_config = zoho_cliq_configs(:zoho_cliq_config_one)
    get edit_zoho_cliq_config_path(zoho_cliq_config)
    check_not_authenticated
  end

  test 'authenticated super_admin only can edit zoho_cliq_config' do
    zoho_cliq_config = zoho_cliq_configs(:zoho_cliq_config_one)
    sign_in users(:staffuser)
    get edit_zoho_cliq_config_path(zoho_cliq_config)
    check_not_authorized
    sign_in users(:superadmin)
    get edit_zoho_cliq_config_path(zoho_cliq_config)
    assert_response 200
  end

  test 'authenticated super_admin can update zoho_cliq_config' do
    user = users(:superadmin)
    sign_in user
    zoho_cliq_config = zoho_cliq_configs(:zoho_cliq_config_one)
    new_values = {
      new_bot_name: 'FDEHFOIUHZ',
      new_webhook_domain: 'https://some_webhook_domain.com',
      new_creator: user,
      new_users: []
    }
    assert_not_equal zoho_cliq_config.bot_name, new_values[:new_bot_name]
    put zoho_cliq_config_path(zoho_cliq_config), params: {
      zoho_cliq_config: form_data(new_values)
    }
    assert_redirected_to zoho_cliq_configs_path
    zoho_cliq_config.reload
    check_model_saved_data(zoho_cliq_config, new_values)
  end

  test 'unauthenticated cannot delete zoho_cliq_config' do
    zoho_cliq_config = zoho_cliq_configs(:zoho_cliq_config_one)
    delete zoho_cliq_config_path(zoho_cliq_config)
    check_not_authenticated
  end

  test 'authenticated super_admin only can delete zoho_cliq_config' do
    zoho_cliq_config = zoho_cliq_configs(:zoho_cliq_config_one)
    sign_in users(:staffuser)
    delete zoho_cliq_config_path(zoho_cliq_config)
    check_not_authorized
    sign_in users(:superadmin)
    delete zoho_cliq_config_path(zoho_cliq_config)
    assert_redirected_to zoho_cliq_configs_path
  end

  private

  # Assertions on Mapper
  def check_model_saved_data(zoho_cliq_config, new_values)
    assert_equal zoho_cliq_config.name, new_values[:new_bot_name]
    assert_equal zoho_cliq_config.bot_name, new_values[:new_bot_name]
    assert_equal zoho_cliq_config.webhook_domain, new_values[:new_webhook_domain]
    new_url = "#{new_values[:new_webhook_domain]}api/v2/bots/#{new_values[:new_bot_name]}" \
              "/incoming?zapikey=#{new_values[:new_zapikey]}"
    assert_equal zoho_cliq_config.url, new_url
    assert_equal zoho_cliq_config.api_key, new_values[:new_zapikey]
    assert_equal zoho_cliq_config.creator, new_values[:new_creator]
    assert_equal zoho_cliq_config.user_ids, new_values[:new_users]
  end

  def form_data(new_values)
    {
      bot_name: new_values[:new_bot_name],
      webhook_domain: new_values[:new_webhook_domain],
      api_key: new_values[:new_zapikey],
      user_ids: new_values[:new_users]
    }
  end
end
