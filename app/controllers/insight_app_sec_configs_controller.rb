# frozen_string_literal: true

class InsightAppSecConfigsController < ApplicationController
  include BouncerController

  before_action :set_insight_app_sec_config, only: %i[show edit update destroy import_scans
                                                      update_scans delete_scan]
  before_action :set_collection_section_header, only: %i[index]
  before_action :set_member_section_header, only: %i[show]

  def index
    common_breadcrumb
    @q_base = policy_scope(InsightAppSecConfig).includes(:teams)
    @q = @q_base.ransack params[:q]
    @q.sorts = ['name asc', 'created_at desc'] if @q.sorts.blank?
    @insight_app_sec_configs = @q.result.page(params[:page]).per(params[:per_page])
  end

  def show
    common_breadcrumb
    add_breadcrumb @insight_app_sec_config.name
  end

  def new
    @insight_app_sec_config = InsightAppSecConfig.new
    new_data
  end

  def edit
    edit_data
  end

  def create
    @insight_app_sec_config = InsightAppSecConfig.new(insight_app_sec_config_params)
    if @insight_app_sec_config.save
      redirect_to @insight_app_sec_config
    else
      new_data
      render 'new'
    end
  end

  def update
    if @insight_app_sec_config.update(insight_app_sec_config_params)
      redirect_to @insight_app_sec_config
    else
      edit_data
      render 'edit'
    end
  end

  def destroy
    if @insight_app_sec_config.destroy
      flash[:notice] = t('insight_app_sec_configs.notices.deletion_success')
    else
      flash[:alert] = t('insight_app_sec_configs.notices.deletion_failure')
    end
    redirect_to insight_app_sec_configs_path
  end

  # Imports
  def import_scans
    InsightAppSecImportJob.perform_later(current_user, @insight_app_sec_config)
    notify_and_redirect('settings.import_scans')
  end

  # Update
  def update_scans
    InsightAppSecUpdateJob.perform_later(current_user, @insight_app_sec_config, params[:reference])
    notify_and_redirect('settings.import_scans')
  end

  # DELETE
  def delete_scan
    if params[:scan_id].present?
      begin
        scan = @insight_app_sec_config.wa_scans.recently_launched.find(params[:scan_id])
        scan.destroy
        flash.now[:notice] = t('settings.notices.deleted')
      rescue ActiveRecord::RecordNotFound
        flash.now[:alert] = t('settings.notices.wrong_value')
      end
    else
      flash[:alert] = t('settings.notices.no_selection')
    end
    redirect_to @insight_app_sec_config
  end

  private

  def authorize!
    authorize(InsightAppSecConfig)
  end

  def common_breadcrumb
    add_home_to_breadcrumb
    add_breadcrumb t('insight_app_sec_configs.section_title'), :insight_app_sec_configs_url
  end

  def new_data
    common_breadcrumb
    add_breadcrumb t('insight_app_sec_configs.actions.create')
    @app_section = make_section_header(
      title: t('insight_app_sec_configs.actions.create'),
      actions: [InsightAppSecConfigsHeaders.new.action(:back, :insight_app_sec_configs)]
    )
  end

  def edit_data
    common_breadcrumb
    add_breadcrumb(
      @insight_app_sec_config.name,
      insight_app_sec_config_path(@insight_app_sec_config)
    )
    add_breadcrumb t('insight_app_sec_configs.actions.edit')
    @app_section = make_section_header(
      title: t(
        'insight_app_sec_configs.pages.edit',
        insight_app_sec_config: @insight_app_sec_config.name
      ),
      actions: [
        InsightAppSecConfigsHeaders.new.action(
          :back, insight_app_sec_config_path(@insight_app_sec_config)
        )
      ]
    )
  end

  def insight_app_sec_config_params
    params.require(:insight_app_sec_config)
          .permit(policy(InsightAppSecConfig).permitted_attributes)
  end

  def set_insight_app_sec_config
    id = params[:id] || params[:insight_app_sec_config_id]
    handle_unscoped { @insight_app_sec_config = policy_scope(InsightAppSecConfig).find(id) }
  end

  # HEADERS
  def set_collection_section_header
    @app_section = make_section_header(
      title: t('insight_app_sec_configs.section_title'),
      actions: [InsightAppSecConfigsHeaders.new.action(:create, nil)]
    )
  end

  def set_member_section_header
    insight_app_sec_configs_h = InsightAppSecConfigsHeaders.new
    @app_section = make_section_header(
      title: @insight_app_sec_config.name,
      actions: [insight_app_sec_configs_h.action(:edit, @insight_app_sec_config)],
      other_actions: [insight_app_sec_configs_h.action(:destroy, @insight_app_sec_config)]
    )
  end

  def notify_and_redirect(translation_key)
    redirect_to @insight_app_sec_config, notice: t(translation_key)
  end
end
