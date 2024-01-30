# frozen_string_literal: true

# https://api.slack.com/search?query=conversations_list

require 'test_helper'
require 'utils/stubs/fake_slack'

class SlackConfigsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  SLACK_TEAM = 'Slack team'
  SLACK_ENTREPRISE = 'Slack entreprise'
  SLACK_ACCESS_TOKEN = 'xoxb-17653672481-19874698323-pdFZKVeTuE8sk7oOcBrzbqgy'

  test 'unauthenticated cannot list slack_configs' do
    get slack_configs_path
    check_not_authenticated
  end

  test 'authenticated super_admin only can list slack_configs' do
    sign_in users(:staffuser)
    get slack_configs_path
    check_not_authorized
    sign_in users(:superadmin)
    get slack_configs_path
    assert_response 200
  end

  #### SLACK APPLICATIONS ####

  test 'unauthenticated cannot add new slack application' do
    get new_slack_application_path
    check_not_authenticated
  end

  test 'authenticated super admin only can add new slack application' do
    sign_in users(:staffuser)
    get new_slack_application_path
    check_not_authorized
    sign_in users(:superadmin)
    get new_slack_application_path
    assert_response 200
  end

  test 'authenticated super admin only can create slack application' do
    sign_in users(:staffuser)
    new_values = {
      new_name: 'zefzedzed',
      new_app_id: 'gezfezgez',
      new_client_id: 'gezgezgze',
      new_client_secret: 'gezgezgez',
      new_signing_secret: 'fezgezg'
    }
    post slack_applications_path, params: {
      slack_application: slack_application_form_data(new_values)
    }
    check_not_authorized
    sign_in users(:superadmin)
    post slack_applications_path, params: {
      slack_application: slack_application_form_data(new_values)
    }
    assert_redirected_to :slack_configs
  end

  test 'unauthenticated cannot edit slack application' do
    slack_app = slack_applications(:slack_application_one)
    get edit_slack_application_path(slack_app)
    check_not_authenticated
  end

  test 'authenticated super admin only can edit slack application' do
    slack_app = slack_applications(:slack_application_one)
    sign_in users(:staffuser)
    get edit_slack_application_path(slack_app)
    check_not_authorized
    sign_in users(:superadmin)
    get edit_slack_application_path(slack_app)
    assert_response 200
  end

  test 'authenticated super admin only can update slack application' do
    sign_in users(:staffuser)
    slack_app = slack_applications(:slack_application_one)
    new_values = {
      new_name: 'zefzedzed',
      new_app_id: 'gezfezgez',
      new_client_id: 'gezgezgze',
      new_client_secret: 'gezgezgez',
      new_signing_secret: 'fezgezg'
    }
    put slack_application_path(slack_app), params: {
      slack_application: slack_application_form_data(new_values)
    }
    check_not_authorized
    sign_in users(:superadmin)
    put slack_application_path(slack_app), params: {
      slack_application: slack_application_form_data(new_values)
    }
    assert_redirected_to :slack_configs
  end

  test 'authenticated super admin only can delete slack application' do
    slack_app = slack_applications(:slack_application_one)
    sign_in users(:staffuser)
    delete slack_application_path(slack_app)
    check_not_authorized
    sign_in users(:superadmin)
    delete slack_application_path(slack_app)
    assert_redirected_to :slack_configs
  end

  #### SLACK CONFIGS ####

  test 'slack_config cannot be created if no code returned during oauth' do
    oauth_response = JSON.parse(
      File.read('test/fixtures/files/slack/oauth_ok_with_incoming_webhook.json')
    )
    new_name = "#{SLACK_ENTREPRISE}-#{SLACK_TEAM}"
    assert SlackConfig.find_by("name like '#{new_name}-%'").blank?
    Slack::Web::Client.stub_any_instance(:oauth_v2_access, oauth_response) do
      # GIVEN
      # an authenticated super admin user
      user = users(:superadmin)
      sign_in user
      # WHEN
      # slack returns data back to csis after 'Add to Slack' click
      get slack_oauth_path(
        code: '',
        state: OauthService.generate_slack_state(SlackApplication.last, user)
      )
      # THEN
      # A new SlackConfig is created with corresponding data
      assert SlackConfig.find_by("name like '#{new_name}-%'").blank?
    end
  end

  test 'authenticated super_admin only can create new slack config with incoming webhook' do
    oauth_resp = JSON.parse(
      File.read('test/fixtures/files/slack/oauth_ok_with_incoming_webhook.json')
    )
    conversations_list_resp = FakeSlack::ConversationsListResponse.new('conversations_list_ok')
    new_name = "#{SLACK_ENTREPRISE}-#{SLACK_TEAM}"
    assert SlackConfig.find_by("name like '#{new_name}-%'").blank?
    Slack::Web::Client.stub_any_instance(:conversations_list, conversations_list_resp) do
      Slack::Web::Client.stub_any_instance(:oauth_v2_access, oauth_resp) do
        # GIVEN
        # an authenticated super admin user
        user = users(:superadmin)
        sign_in user
        # WHEN
        # slack returns data back to csis after 'Add to Slack' click
        get slack_oauth_path(
          code: 'blabla', state: OauthService.generate_slack_state(SlackApplication.last, user)
        )
        # THEN
        # A new SlackConfig is created with corresponding data
        new_slack_config = SlackConfig.find_by("name like '#{new_name}-%'")
        assert new_slack_config.present?
        # And channel name corresponds to the one specified in incoming_webhook
        assert_equal 'C12345678', new_slack_config.channel_id
        assert_equal 'general', new_slack_config.channel_name
      end
    end
  end

  test 'authenticated super_admin only can create new slack config w/out incoming webhook' do
    oauth_resp = JSON.parse(
      File.read('test/fixtures/files/slack/oauth_ok_without_incoming_webhook.json')
    )
    conversations_list_resp = FakeSlack::ConversationsListResponse.new('conversations_list_ok')
    new_name = "#{SLACK_ENTREPRISE}-#{SLACK_TEAM}"
    assert SlackConfig.find_by("name like '#{new_name}-%'").blank?
    Slack::Web::Client.stub_any_instance(:conversations_list, conversations_list_resp) do
      Slack::Web::Client.stub_any_instance(:oauth_v2_access, oauth_resp) do
        # GIVEN
        # an authenticated super admin user
        user = users(:superadmin)
        sign_in user
        # WHEN
        # slack returns data back to csis after 'Add to Slack' click
        get slack_oauth_path(
          code: 'blabla', state: OauthService.generate_slack_state(SlackApplication.last, user)
        )
        # THEN
        # A new SlackConfig is created with corresponding data
        new_slack_config = SlackConfig.find_by("name like '#{new_name}-%'")
        assert new_slack_config.present?
        # And channel name corresponds to the first channel available in conversations_list
        assert_equal new_slack_config.channel_id, 'C012AB3CD'
        assert_equal new_slack_config.channel_name, 'general'
      end
    end
  end

  test 'slack_config is not created if oauth response is ko' do
    oauth_resp = JSON.parse(
      File.read('test/fixtures/files/slack/oauth_ko.json')
    )
    new_name = "#{SLACK_ENTREPRISE}-#{SLACK_TEAM}"
    assert SlackConfig.find_by("name like '#{new_name}-%'").blank?
    Slack::Web::Client.stub_any_instance(:oauth_v2_access, oauth_resp) do
      # GIVEN
      # an authenticated super admin user
      user = users(:superadmin)
      sign_in user
      # WHEN
      # slack returns data back to csis after 'Add to Slack' click
      get slack_oauth_path(
        code: 'blabla', state: OauthService.generate_slack_state(SlackApplication.last, user)
      )
      # THEN
      # A new SlackConfig is not created
      new_slack_config = SlackConfig.find_by("name like '#{new_name}-%'")
      assert new_slack_config.blank?
    end
  end

  test 'slack_config cannot be created if state given by slack API does not match' do
    oauth_response = JSON.parse(
      File.read('test/fixtures/files/slack/oauth_ok_with_incoming_webhook.json')
    )
    new_name = "#{SLACK_ENTREPRISE}-#{SLACK_TEAM}"
    assert SlackConfig.find_by("name like '#{new_name}-%'").blank?
    Slack::Web::Client.stub_any_instance(:oauth_v2_access, oauth_response) do
      # GIVEN
      # an authenticated super admin user
      user = users(:superadmin)
      sign_in user
      # WHEN
      # slack returns data back to csis after 'Add to Slack' click
      get slack_oauth_path(
        code: 'blabla',
        state: OauthService.generate_slack_state(SlackApplication.last, users(:staffuser))
      )
      # THEN
      # A new SlackConfig is created with corresponding data
      assert SlackConfig.find_by("name like '#{new_name}-%'").blank?
    end
  end

  test 'unauthenticated cannot edit slack config' do
    slack_config = slack_configs(:slack_config_one)
    get edit_slack_config_path(slack_config)
    check_not_authenticated
  end

  test 'authenticated super_admin only can edit slack_config' do
    # GIVEN a slack config
    slack_config = slack_configs(:slack_config_one)
    conversations_list_resp = FakeSlack::ConversationsListResponse.new('conversations_list_ok')
    sign_in users(:staffuser)
    # WHEN trying to edit as a not super admin
    Slack::Web::Client.stub_any_instance(:conversations_list, conversations_list_resp) do
      get edit_slack_config_path(slack_config)
    end
    # THEN unscoped as staffuser is not a super admin
    check_unscoped
    # WHEN trying to edit as a super_admin
    sign_in users(:superadmin)
    Slack::Web::Client.stub_any_instance(:conversations_list, conversations_list_resp) do
      get edit_slack_config_path(slack_config)
    end
    # THEN OK
    assert_response 200
  end

  # test 'authenticated super admin only can edit slack config' do
  #   slack_config = slack_configs(:slack_config_one)
  #   sign_in users(:staffuser)
  #   get edit_slack_config_path(slack_config)
  #   check_not_authorized
  #   sign_in users(:superadmin)
  #   get edit_slack_config_path(slack_config)
  #   assert_response 200
  # end

  test 'authenticated super_admin can update slack config' do
    # GIVEN
    conversations_list_resp = FakeSlack::ConversationsListResponse.new('conversations_list_ok')
    slack_config = slack_configs(:slack_config_one)
    new_channel_id = 'FDEHFOIUHZ'
    assert_not_equal slack_config.channel_id, new_channel_id
    Slack::Web::Client.stub_any_instance(:conversations_list, conversations_list_resp) do
      # WHEN not super admin
      sign_in users(:staffuser)
      put slack_config_path(slack_config), params: {
        slack_config: form_data(new_channel_id)
      }
      # THEN unscoped
      check_unscoped
      # WHEN super admin
      sign_in users(:superadmin)
      put slack_config_path(slack_config), params: {
        slack_config: form_data(new_channel_id)
      }
      # THEN slack config is updated
      assert_redirected_to slack_configs_path
      slack_config.reload
      assert_equal slack_config.channel_id, new_channel_id
      assert_equal [], slack_config.users
      # with a channel among those availables
    end
  end

  private

  def form_data(new_channel_id)
    {
      channel_id: new_channel_id,
      user_ids: []
    }
  end

  def slack_application_form_data(new_values)
    {
      name: new_values[:new_name],
      app_id: new_values[:new_app_id],
      client_id: new_values[:new_client_id],
      client_secret: new_values[:new_client_secret],
      signing_secret: new_values[:new_signing_secret]
    }
  end
end
