# frozen_string_literal: true

class SlackConfigsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize!, only: %i[index oauth]
  before_action :set_whodunnit, except: %i[oauth]
  before_action :set_slack_application, only: %i[oauth]
  before_action :set_slack_applications, only: %i[index]
  before_action :set_slack_config, only: %i[edit update destroy]
  before_action :set_slack_channels, only: %i[edit update]
  before_action :authorize_slack_config!, only: %i[edit update destroy]
  before_action :set_collection_section_header, only: %i[index]
  before_action :set_member_section_header, only: %i[edit]

  def self.controller_path
    'chat_configs/slack_config'
  end

  SORT_ARY = ['name asc', 'created_at desc'].freeze

  # <tt>GET /slack_configs</tt>
  # List slack_applications
  # For each, display all linked slack_configs
  def index
    common_breadcrumb
    @slack_applications = filtered_list(policy_scope(SlackApplication), SORT_ARY)
    @application_headers = SlackApplicationsHeaders.new
  end

  # <tt>GET /slack/oauth </tt>
  # When a user authorizes an app,
  # a code query parameter is passed on the oAuth endpoint + a state param.
  # If that code is not there, we respond with an error message
  # The state param is used to get slack app id back and confirm
  # current_user
  # Format: state=slack_app.id:current_user.id
  # We'll do a POST call to Slack's `oauth.v2.access` endpoint,
  # passing our app's client ID, client secret,
  # and the code we just got as query parameters.
  def oauth
    raise StandardError if params[:code].blank?

    options = Configs::SlackConfigService.build_oauth_options(@slack_application, params[:code])
    response = Slack::Web::Client.new.oauth_v2_access(options)
    notice = Configs::SlackConfigService.handle_oauth_response(
      @slack_application, response, options, current_user
    )
    redirect_to slack_configs_path, notice: notice
  rescue StandardError => e
    logger.error("Error during Slack oauth: #{e.message}")
    notice = t('slack_configs.notices.creation_failure')
    logger.info(notice)
    redirect_to slack_configs_path, notice: notice
  end

  def show
    common_breadcrumb
    add_breadcrumb @slack_config.name
    render 'show'
  end

  def edit
    edit_data
  end

  def update
    fetch_existing_channel
    if @slack_config.update(slack_config_params)
      redirect_to slack_configs_path
    else
      edit_data
      render 'edit'
    end
  end

  def destroy
    if @slack_config.destroy
      flash[:notice] = t('slack_configs.notices.deletion_success')
    else
      flash[:alert] = t('slack_configs.notices.deletion_failure')
    end
    redirect_to slack_configs_path
  end

  private

  def common_breadcrumb
    add_home_to_breadcrumb
    add_breadcrumb t('slack_configs.section_title'), :slack_configs_url
  end

  def edit_data
    common_breadcrumb
    add_breadcrumb @slack_config.name
    add_breadcrumb t('slack_configs.actions.edit')
    @app_section = make_section_header(
      title: t('slack_configs.pages.edit', chat_config: @slack_config.name),
      actions: [SlackConfigsHeaders.new.action(:back, slack_config_path(@slack_config))]
    )
  end

  def slack_config_params
    params.require(:slack_config).permit(policy(SlackConfig).permitted_attributes)
  end

  # We can authorize all methods here as authorizations do not need further record informations
  def authorize!
    authorize(SlackConfig)
  end

  def authorize_slack_config!
    authorize(@slack_config)
  end

  def set_slack_config
    id = params[:id] || params[:chat_config_id]
    handle_unscoped do
      @slack_config = policy_scope(SlackConfig).find(id)
    end
  end

  def set_slack_channels
    @channels = Configs::SlackConfigService.fetch_channels(@slack_config)
  end

  def set_slack_application
    handle_unscoped do
      # We get slack application back from url params
      # code=xxx&state=slack_app.id:current_user.id
      # Here we should generate a temporary code to store for user
      raise ActiveRecord::RecordNotFound if params[:state].blank?

      state_ary = params[:state].split(':')
      raise ActiveRecord::RecordNotFound unless state_for_current_user?(state_ary)

      @slack_application = policy_scope(SlackApplication).find(state_ary[0])
    end
  end

  def state_for_current_user?(state_ary)
    state_ary[1] == current_user.id
  end

  def set_slack_applications
    @slack_applications = filtered_list(policy_scope(SlackApplication), SORT_ARY)
  end

  def fetch_existing_channel
    # Find channel name corresponding to channel_id and update
    # corresponding slack_config_params
    found_channel = @channels.find { |channel| channel[1] == slack_config_params['channel_id'] }
    slack_config_params['channel_name'] = 'default' if found_channel.blank?
  end

  # HEADERS
  def set_collection_section_header
    @headers = SlackConfigsHeaders.new
    @app_section = make_section_header(
      title: t('slack_configs.section_title'),
      filter_btn: true,
      actions: [@headers.action(:create_app, nil)],
      scopes: @headers.tabs(policy_headers(SlackConfig, :list).tabs, nil)
    )
  end

  def set_member_section_header
    slack_configs_h = SlackConfigsHeaders.new
    @app_section = make_section_header(
      title: @slack_config.name,
      actions: [slack_configs_h.action(:edit, @slack_config)],
      other_actions: [slack_configs_h.action(:destroy, @slack_config)]
    )
  end
end
