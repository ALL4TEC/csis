# frozen_string_literal: true

class IdpConfigsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize!, only: %i[index new create show]
  before_action :set_whodunnit
  before_action :set_idp_config, only: %i[show edit update destroy activate deactivate]
  before_action :set_trashed_idp_config, only: %i[restore]
  before_action :authorize_idp_config!, only: %i[show edit update destroy activate deactivate]
  before_action :set_collection_section_header, only: %i[index]
  before_action :set_member_section_header, only: %i[show]

  def index
    common_breadcrumb
    @q_base = policy_scope(IdpConfig)
    @q = @q_base.ransack params[:q]
    @q.sorts = ['name asc', 'created_at desc'] if @q.sorts.blank?
    @idp_configs = @q.result.page(params[:page]).per(params[:per_page])
  end

  def show
    common_breadcrumb
    add_breadcrumb @idp_config.name
  end

  def new
    @idp_config = IdpConfig.new
    new_data
  end

  def edit
    edit_data
  end

  def create
    @idp_config = IdpConfig.new(idp_config_params)
    if @idp_config.save
      redirect_to @idp_config
    else
      new_data
      render 'new'
    end
  end

  def update
    if @idp_config.update(idp_config_params)
      redirect_to @idp_config
    else
      edit_data
      render 'edit'
    end
  end

  def restore
    @idp_config.undiscard
    redirect_to idp_configs_path, notice: t('idp_configs.notices.restored')
  end

  def destroy
    if @idp_config.discard
      flash[:notice] = t('idp_configs.notices.deletion_success')
    else
      flash[:alert] = t('idp_configs.notices.deletion_failure')
    end
    redirect_to idp_configs_path
  end

  def activate
    @idp_config.activate
    redirect_to idp_configs_path, notice: t('idp_configs.notices.activated')
  end

  def deactivate
    @idp_config.deactivate
    redirect_to idp_configs_path, notice: t('idp_configs.notices.deactivated')
  end

  private

  def common_breadcrumb
    add_home_to_breadcrumb
    add_breadcrumb t('idp_configs.section_title'), :idp_configs_url
  end

  def new_data
    common_breadcrumb
    add_breadcrumb t('idp_configs.actions.create')
    @app_section = make_section_header(
      title: t('idp_configs.actions.create'),
      actions: [IdpConfigsHeaders.new.action(:back, back_in_history)]
    )
  end

  def edit_data
    common_breadcrumb
    add_breadcrumb @idp_config.name, idp_config_path(@idp_config)
    add_breadcrumb t('idp_configs.actions.edit')
    @app_section = make_section_header(
      title: t('idp_configs.pages.edit', idp_config: @idp_config.name),
      actions: [IdpConfigsHeaders.new.action(:back, back_in_history)]
    )
  end

  def idp_config_params
    params.require(:idp_config).permit(policy(IdpConfig).permitted_attributes)
  end

  def authorize!
    authorize(IdpConfig)
  end

  def set_idp_config
    store_request_referer(idp_configs_path)
    handle_unscoped { @idp_config = policy_scope(IdpConfig).find(params[:id]) }
  end

  def set_trashed_idp_config
    handle_unscoped { @idp_config = policy_scope(IdpConfig).trashed.find(params[:id]) }
  end

  def authorize_idp_config!
    authorize(@idp_config)
  end

  def set_collection_section_header
    @headers = IdpConfigsHeaders.new
    @app_section = make_section_header(
      title: t('idp_configs.section_title'),
      actions: @headers.actions(policy_headers(:idp_config, :collection).actions, nil)
    )
  end

  def set_member_section_header
    idp_configs_headers = IdpConfigsHeaders.new
    headers = policy_headers(:idp_config, :member, @idp_config)
    @app_section = make_section_header(
      title: @idp_config.name,
      actions: idp_configs_headers.actions(headers.actions, @idp_config),
      other_actions: idp_configs_headers.actions(headers.other_actions, @idp_config)
    )
  end
end
