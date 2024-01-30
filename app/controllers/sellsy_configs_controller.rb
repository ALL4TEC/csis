# frozen_string_literal: true

class SellsyConfigsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize!
  before_action :set_whodunnit
  before_action :set_sellsy_config, only: %i[show edit update destroy import]
  before_action :set_collection_section_header, only: %i[index]
  before_action :set_member_section_header, only: %i[show]

  def index
    common_breadcrumb
    @q_base = policy_scope(SellsyConfig)
    @q = @q_base.ransack params[:q]
    @q.sorts = ['name asc', 'created_at desc'] if @q.sorts.blank?
    @sellsy_configs = @q.result.page(params[:page]).per(params[:per_page])
  end

  def show
    common_breadcrumb
    add_breadcrumb @sellsy_config.name
  end

  def new
    @sellsy_config = SellsyConfig.new
    new_data
  end

  def edit
    edit_data
  end

  def create
    @sellsy_config = SellsyConfig.new(sellsy_config_params)
    if @sellsy_config.save
      redirect_to @sellsy_config
    else
      new_data
      render 'new'
    end
  end

  def update
    if @sellsy_config.update(sellsy_config_params)
      redirect_to @sellsy_config
    else
      edit_data
      render 'edit'
    end
  end

  def destroy
    if @sellsy_config.destroy
      flash[:notice] = t('sellsy_configs.notices.deletion_success')
    else
      flash[:alert] = t('sellsy_configs.notices.deletion_failure')
    end
    redirect_to sellsy_configs_path
  end

  def import
    if Rails.application.config.sellsy_enabled
      Importers::SellsyImportJob.perform_later(current_user, @sellsy_config)
      flash.now[:notice] = t('settings.import_sellsy')
    else
      flash[:alert] = t('settings.import_sellsy_canceled')
    end
    redirect_to @sellsy_config
  end

  private

  def common_breadcrumb
    add_home_to_breadcrumb
    add_breadcrumb t('sellsy_configs.section_title'), :sellsy_configs_url
  end

  def new_data
    common_breadcrumb
    add_breadcrumb t('sellsy_configs.actions.create')
    @app_section = make_section_header(
      title: t('sellsy_configs.actions.create'),
      actions: [SellsyConfigsHeaders.new.action(:back, :sellsy_configs)]
    )
  end

  def edit_data
    common_breadcrumb
    add_breadcrumb @sellsy_config.name, sellsy_config_path(@sellsy_config)
    add_breadcrumb t('sellsy_configs.actions.edit')
    @app_section = make_section_header(
      title: t('sellsy_configs.pages.edit', sellsy_config: @sellsy_config.name),
      actions: [SellsyConfigsHeaders.new.action(:back, sellsy_config_path(@sellsy_config))]
    )
  end

  def sellsy_config_params
    params.require(:sellsy_config).permit(policy(SellsyConfig).permitted_attributes)
  end

  # We can authorize all methods here as authorizations do not need further record informations
  def authorize!
    authorize(SellsyConfig)
  end

  def set_sellsy_config
    id = params[:id] || params[:sellsy_config_id]
    handle_unscoped { @sellsy_config = policy_scope(SellsyConfig).find(id) }
  end

  # HEADERS
  def set_collection_section_header
    @app_section = make_section_header(
      title: t('sellsy_configs.section_title'),
      actions: [
        SellsyConfigsHeaders.new.action(:create, nil)
      ]
    )
  end

  def set_member_section_header
    sellsy_configs_h = SellsyConfigsHeaders.new
    @app_section = make_section_header(
      title: @sellsy_config.name,
      actions: [sellsy_configs_h.action(:edit, @sellsy_config)],
      other_actions: [sellsy_configs_h.action(:destroy, @sellsy_config)]
    )
  end
end
