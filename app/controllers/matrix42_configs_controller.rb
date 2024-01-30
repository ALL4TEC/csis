# frozen_string_literal: true

class Matrix42ConfigsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize!, except: %i[oauth destroy]
  before_action :set_whodunnit, except: %i[oauth]
  before_action :set_matrix42_config, only: %i[show edit update destroy oauth]
  before_action :authorize_matrix42_config!, only: %i[edit update destroy]
  before_action :set_collection_section_header, only: %i[index]
  before_action :set_member_section_header, only: %i[show]

  # get '/matrix42_configs'
  def index
    common_breadcrumb
    @headers = Matrix42ConfigsHeaders.new
    @matrix42_configs =
      filtered_list(policy_scope(Matrix42Config), ['name asc', 'created_at desc'])
  end

  # get '/matrix42_configs/:id'
  def show
    common_breadcrumb
    add_breadcrumb @matrix42_config.name
  end

  # get '/matrix42_configs/new'
  def new
    @matrix42_config = Matrix42Config.new
    new_data
  end

  # get '/matrix42_configs/:id/edit'
  def edit
    edit_data
  end

  # post '/matrix42_configs'
  def create
    @matrix42_config = Matrix42Config.new(matrix42_config_params)
    @matrix42_config.status = :url_ko
    @matrix42_config.need_refresh_at = DateTime.current.ago(10)

    if @matrix42_config.save
      begin
        Matrix42::Wrapper.new(@matrix42_config)
        redirect_to matrix42_configs_path
      rescue Matrix42::Error
        # exception when creating wrapper means URL or auth token are not valid
        redirect_to @matrix42_config
      end
    else
      new_data
      render 'new'
    end
  end

  # patch '/matrix42_configs/:id'
  def update
    params = matrix42_config_params.merge({ status: :url_ko })
    params['api_key'] = @matrix42_config.api_key if params['api_key'].empty?
    if @matrix42_config.update(params)
      begin
        Matrix42::Wrapper.new(@matrix42_config)
        redirect_to matrix42_configs_path
      rescue Matrix42::Error
        redirect_to @matrix42_config
      end
    else
      edit_data
      render 'edit'
    end
  end

  # delete '/matrix42_configs/:id'
  def destroy
    if @matrix42_config.destroy
      flash[:notice] = t('matrix42_configs.notices.deletion_success')
    else
      flash[:alert] = t('matrix42_configs.notices.deletion_failure')
    end
    redirect_to matrix42_configs_path
  end

  private

  def authorize!
    authorize(Matrix42Config)
  end

  def authorize_matrix42_config!
    authorize(@matrix42_config)
  end

  def new_data
    common_breadcrumb
    add_breadcrumb t('matrix42_configs.actions.create')
    @app_section = make_section_header(
      title: t('matrix42_configs.actions.create'),
      help: true,
      actions: [Matrix42ConfigsHeaders.new.action(:back, :matrix42_configs)]
    )
  end

  def edit_data
    common_breadcrumb
    add_breadcrumb @matrix42_config.name, matrix42_config_path(@matrix42_config)
    add_breadcrumb t('matrix42_configs.actions.edit')
    @app_section = make_section_header(
      title: t('matrix42_configs.pages.edit', matrix42_config: @matrix42_config.name),
      actions: [Matrix42ConfigsHeaders.new.action(
        :back, matrix42_config_path(@matrix42_config)
      )]
    )
  end

  def set_matrix42_config
    id = params[:id] || params[:matrix42_config_id] || params[:state]
    handle_unscoped { @matrix42_config = policy_scope(Matrix42Config).find(id) }
  end

  def matrix42_config_params
    params.require(:matrix42_config).permit(policy(Matrix42Config).permitted_attributes)
  end

  def common_breadcrumb
    add_home_to_breadcrumb
    add_breadcrumb t('matrix42_configs.section_title'), :matrix42_configs_url
  end

  def set_collection_section_header
    @headers = Matrix42ConfigsHeaders.new
    @app_section = make_section_header(
      title: t('matrix42_configs.section_title'),
      actions: [
        @headers.action(:create, nil)
      ],
      filter_btn: true
    )
  end

  def set_member_section_header
    matrix42_configs_h = Matrix42ConfigsHeaders.new
    @app_section = make_section_header(
      title: @matrix42_config.name,
      actions: [matrix42_configs_h.action(:edit, @matrix42_config)],
      other_actions: [matrix42_configs_h.action(:destroy, @matrix42_config)]
    )
  end
end
