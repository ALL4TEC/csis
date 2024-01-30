# frozen_string_literal: true

class ServicenowConfigsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize!, except: %i[oauth destroy]
  before_action :set_whodunnit, except: %i[oauth]
  before_action :set_servicenow_config, only: %i[show edit update destroy oauth]
  before_action :authorize_servicenow_config!, only: %i[edit update destroy]
  before_action :set_collection_section_header, only: %i[index]
  before_action :set_member_section_header, only: %i[show]

  # get '/servicenow_configs', to: 'servicenow_configs#index'
  def index
    common_breadcrumb
    @headers = ServicenowConfigsHeaders.new
    @servicenow_configs =
      filtered_list(policy_scope(ServicenowConfig), ['name asc', 'created_at desc'])
  end

  # get '/servicenow_configs/:id', to: 'servicenow_configs#show'
  def show
    common_breadcrumb
    add_breadcrumb @servicenow_config.name
  end

  # get '/servicenow_configs/new', to: 'servicenow_configs#new'
  def new
    @servicenow_config = ServicenowConfig.new
    new_data
  end

  # post '/servicenow_configs', to: 'servicenow_configs#create'
  def edit
    edit_data
  end

  # get '/servicenow_configs', to: 'servicenow_configs#edit'
  def create
    @servicenow_config = ServicenowConfig.new(servicenow_config_params)
    @servicenow_config.status = :ko

    if @servicenow_config.save
      redirect_to Servicenow::Wrapper.new(@servicenow_config).authorization_url,
        allow_other_host: true
    else
      new_data
      render 'new'
    end
  end

  # patch '/servicenow_configs/:id', to: 'servicenow_configs#update'
  def update
    params = servicenow_config_params.merge({ status: :ko })
    params['api_key'] = @servicenow_config.api_key if params['api_key'].empty?
    params['secret_key'] = @servicenow_config.secret_key if params['secret_key'].empty?
    if @servicenow_config.update(params)
      redirect_to Servicenow::Wrapper.new(@servicenow_config).authorization_url,
        allow_other_host: true
    else
      edit_data
      render 'edit'
    end
  end

  # delete '/servicenow_configs/:id', to: 'servicenow_configs#destroy'
  def destroy
    if @servicenow_config.destroy
      flash[:notice] = t('servicenow_configs.notices.deletion_success')
    else
      flash[:alert] = t('servicenow_configs.notices.deletion_failure')
    end
    redirect_to servicenow_configs_path
  end

  # get '/servicenow/oauth', to: 'servicenow_configs#oauth'
  # - code: authorization code
  # - state: servicenow_config id
  def oauth
    # TODO: filter parameters
    handle_oauth(params[:code])
  end

  private

  def handle_oauth(authorization_code)
    Servicenow::Wrapper.new(@servicenow_config).trade_token(authorization_code)
    redirect_to action: 'index'
  rescue Servicenow::Error
    redirect_to @servicenow_config
  end

  def authorize!
    authorize(ServicenowConfig)
  end

  def authorize_servicenow_config!
    authorize(@servicenow_config)
  end

  def new_data
    common_breadcrumb
    add_breadcrumb t('servicenow_configs.actions.create')
    @app_section = make_section_header(
      title: t('servicenow_configs.actions.create'),
      help: true,
      actions: [ServicenowConfigsHeaders.new.action(:back, :servicenow_configs)]
    )
  end

  def edit_data
    common_breadcrumb
    add_breadcrumb @servicenow_config.name, servicenow_config_path(@servicenow_config)
    add_breadcrumb t('servicenow_configs.actions.edit')
    @app_section = make_section_header(
      title: t('servicenow_configs.pages.edit', servicenow_config: @servicenow_config.name),
      actions: [ServicenowConfigsHeaders.new.action(
        :back, servicenow_config_path(@servicenow_config)
      )]
    )
  end

  def set_servicenow_config
    id = params[:id] || params[:servicenow_config_id] || params[:state]
    handle_unscoped { @servicenow_config = policy_scope(ServicenowConfig).find(id) }
  end

  def servicenow_config_params
    params.require(:servicenow_config).permit(policy(ServicenowConfig).permitted_attributes)
  end

  def servicenow_oauth_params
    params.permit(:code, :state)
  end

  def common_breadcrumb
    add_home_to_breadcrumb
    add_breadcrumb t('servicenow_configs.section_title'), :servicenow_configs_url
  end

  def set_collection_section_header
    @headers = ServicenowConfigsHeaders.new
    @app_section = make_section_header(
      title: t('servicenow_configs.section_title'),
      actions: [
        @headers.action(:create, nil)
      ],
      filter_btn: true
    )
  end

  def set_member_section_header
    servicenow_configs_h = ServicenowConfigsHeaders.new
    @app_section = make_section_header(
      title: @servicenow_config.name,
      actions: [servicenow_configs_h.action(:edit, @servicenow_config)],
      other_actions: [servicenow_configs_h.action(:destroy, @servicenow_config)]
    )
  end
end
