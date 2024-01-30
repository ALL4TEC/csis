# frozen_string_literal: true

class JiraConfigsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize!, except: %i[oauth destroy]
  before_action :set_whodunnit, except: %i[oauth]
  before_action :set_jira_config, only: %i[show edit update destroy]
  before_action :authorize_jira_config!, only: %i[edit update destroy]
  before_action :set_collection_section_header, only: %i[index]
  before_action :set_member_section_header, only: %i[show]

  # get '/jira_configs', to: 'jira_configs#index'
  def index
    common_breadcrumb
    @headers = JiraConfigsHeaders.new
    @jira_configs = filtered_list(policy_scope(JiraConfig), ['name asc', 'created_at desc'])
  end

  # get '/jira_configs/:id', to: 'jira_configs#show'
  def show
    common_breadcrumb
    add_breadcrumb @jira_config.name
  end

  # get '/jira_configs/new', to: 'jira_configs#new'
  def new
    @jira_config = JiraConfig.new
    new_data
  end

  # get '/jira_configs', to: 'jira_configs#edit'
  def edit
    edit_data
  end

  # post '/jira_configs', to: 'jira_configs#create'
  def create
    @jira_config = JiraConfig.new(jira_config_params)
    @jira_config.context ||= ''

    # can't use .validate here since login, password, status and expiration_date doesn't exist yet
    if @jira_config.valid_attribute?(:name, :url, :project_id)
      retrieve_request_token('new')
    else
      new_data
      render 'new'
    end
  end

  # put '/jira_configs/:id', to: 'jira_configs#update'
  def update
    if @jira_config.update(jira_config_params)
      retrieve_request_token('edit')
    else
      edit_data
      render 'edit'
    end
  end

  # delete '/jira_configs/:id', to: 'jira_configs#destroy'
  def destroy
    if @jira_config.destroy
      flash[:notice] = t('jira_configs.notices.deletion_success')
    else
      flash[:alert] = t('jira_configs.notices.deletion_failure')
    end
    redirect_to jira_configs_path
  end

  # get '/jira/oauth', to: 'jira_configs#oauth'
  # - oauth_token: request token
  # - oauth_verifier: verification code (or "denied")
  def oauth
    handle_oauth
  end

  private

  def handle_oauth
    # this ugly .all.find has been benchmarked and was instantaneous with 200 JiraConfig in DB
    @jira_config = JiraConfig.all.find { |v| v.login == params[:oauth_token] }
    if jira_oauth_params[:oauth_verifier] == 'denied'
      @jira_config.update(status: 'ko')
      redirect_to @jira_config
    else
      wrapper = Jira::Wrapper.new(@jira_config)
      wrapper.set_request_token
      auth_token = wrapper.auth_token(jira_oauth_params[:oauth_verifier])
      @jira_config.update(
        login: auth_token.token, password: auth_token.secret,
        expiration_date: DateTime.current.advance(years: 5)
      )
      # check access to project_id
      if wrapper.project_exists?
        @jira_config.update(status: 'ok')
        redirect_to action: 'index'
      else
        @jira_config.update(status: 'project_not_found')
        redirect_to @jira_config
      end
    end
  end

  # common steps to #create and #update
  # from_action: 'new' or 'edit'
  def retrieve_request_token(from_action)
    # try to get a request token
    wrapper = Jira::Wrapper.new(@jira_config)
    request_token = ''
    begin
      request_token = wrapper.request_token
    rescue StandardError # can be A LOT of errors: TCP connection failure, OAuth failure...
      @jira_config.errors.add(:url, t('jira_configs.access_error'))
      new_data if from_action == 'new'
      edit_data if from_action == 'edit'
      render from_action
    else
      # store request token/secret in login/password fields
      @jira_config.login = request_token.token
      @jira_config.password = request_token.secret
      # a request token is valid for 10 minutes
      @jira_config.status = 'request'
      @jira_config.expiration_date = DateTime.current.advance(minutes: 10)
      # save and redirect to Jira OAuth validation
      @jira_config.save
      redirect_to request_token.authorize_url
    end
  end

  def authorize!
    authorize(JiraConfig)
  end

  def authorize_jira_config!
    authorize(@jira_config)
  end

  def new_data
    common_breadcrumb
    add_breadcrumb t('jira_configs.actions.create')
    @app_section = make_section_header(
      title: t('jira_configs.actions.create'),
      help: true,
      actions: [JiraConfigsHeaders.new.action(:back, :jira_configs)]
    )
  end

  def edit_data
    common_breadcrumb
    add_breadcrumb @jira_config.name, jira_config_path(@jira_config)
    add_breadcrumb t('jira_configs.actions.edit')
    @app_section = make_section_header(
      title: t('jira_configs.pages.edit', jira_config: @jira_config.name),
      actions: [JiraConfigsHeaders.new.action(:back, jira_config_path(@jira_config))]
    )
  end

  def set_jira_config
    id = params[:id] || params[:jira_config_id]
    handle_unscoped { @jira_config = policy_scope(JiraConfig).find(id) }
  end

  def jira_config_params
    params.require(:jira_config).permit(policy(JiraConfig).permitted_attributes)
  end

  def jira_oauth_params
    params.permit(:oauth_token, :oauth_verifier)
  end

  def common_breadcrumb
    add_home_to_breadcrumb
    add_breadcrumb t('jira_configs.section_title'), :jira_configs_url
  end

  def set_collection_section_header
    @headers = JiraConfigsHeaders.new
    @app_section = make_section_header(
      title: t('jira_configs.section_title'),
      actions: [
        @headers.action(:create, nil)
      ],
      filter_btn: true
    )
  end

  def set_member_section_header
    jira_configs_h = JiraConfigsHeaders.new
    @app_section = make_section_header(
      title: @jira_config.name,
      actions: [jira_configs_h.action(:edit, @jira_config)],
      other_actions: [jira_configs_h.action(:destroy, @jira_config)]
    )
  end
end
