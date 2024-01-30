# frozen_string_literal: true

class QualysConfigsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize!, except: %i[activate deactivate destroy]
  before_action :set_whodunnit
  before_action :set_qualys_config, only: %i[show edit update destroy vulnerabilities_import
                                             wa_scans_import vm_scans_import vm_scans_update
                                             wa_scans_update vm_scan_delete wa_scan_delete
                                             activate deactivate]
  before_action :authorize_qualys_config!, only: %i[activate deactivate destroy]
  before_action :set_collection_section_header, only: %i[index]
  before_action :set_member_section_header, only: %i[show]

  SETTINGS_IMPORT_SCANS = 'settings.import_scans'

  def index
    common_breadcrumb
    @q_base = policy_scope(QualysConfig).includes(:teams, :qualys_vm_clients, :qualys_wa_clients)
    @q = @q_base.ransack params[:q]
    @q.sorts = ['name asc', 'created_at desc'] if @q.sorts.blank?
    @qualys_configs = @q.result.page(params[:page]).per(params[:per_page])
  end

  def show
    common_breadcrumb
    add_breadcrumb @qualys_config.name
  end

  def new
    @qualys_config = QualysConfig.new
    new_data
  end

  def edit
    edit_data
  end

  def create
    @qualys_config = QualysConfig.new(qualys_config_params)
    if @qualys_config.save
      redirect_to @qualys_config
    else
      new_data
      render 'new'
    end
  end

  def update
    if @qualys_config.update(qualys_config_params)
      redirect_to @qualys_config
    else
      edit_data
      render 'edit'
    end
  end

  def activate
    @qualys_config.undiscard
    redirect_to qualys_configs_path
  end

  def deactivate
    @qualys_config.discard
    redirect_to qualys_configs_path
  end

  def destroy
    if @qualys_config.destroy
      flash[:notice] = t('qualys_configs.notices.deletion_success')
    else
      flash[:alert] = t('qualys_configs.notices.deletion_failure')
    end
    redirect_to qualys_configs_path
  end

  # Imports
  # Wa
  def wa_scans_import
    handle_import(:wa) { |opts| import_wa_scans(opts) }
  end

  # Vm
  def vm_scans_import
    handle_import(:vm) { |opts| import_vm_scans(opts) }
  end

  # Updates
  # All Vm
  def vm_scans_update
    handle_import(:vm) { |opts| update_vm_scans(params[:reference], opts) }
  end

  # Wa
  def wa_scans_update
    handle_import(:wa) do |opts|
      update_wa_scans(params[:reference], opts, only: params[:thumb_only], force: params[:force])
    end
  end

  # Import vulnerabilities
  def vulnerabilities_import
    Importers::Qualys::VulnerabilitiesImportJob.perform_later(
      current_user.id, @qualys_config.id, last: params[:last_only].present?
    )
    notify_and_redirect('settings.import_vulnerabilities')
  end

  # VM Scan deletion
  def vm_scan_delete
    delete_scan('vm')
  end

  def wa_scan_delete
    delete_scan('wa')
  end

  private

  def handle_import(kind)
    permitted = params.require(:qualys_config).permit(
      policy(QualysConfig).send(:"permitted_#{kind}_scans_attributes")
    )
    if permitted.permitted?
      opts = QualysConfigsParamsHandler.call(permitted, params[:action])
      yield opts
    else
      notify_and_redirect(FORM_ERROR)
    end
  end

  def delete_scan(kind)
    if params[:scan_id].present?
      begin
        scan = @qualys_config.send(:"#{kind}_scans").recently_launched.find(params[:scan_id])
        scan.destroy
        flash.now[:notice] = t('settings.notices.deleted')
      rescue ActiveRecord::RecordNotFound
        flash.now[:alert] = t('settings.notices.wrong_value')
      end
    else
      flash[:alert] = t('settings.notices.no_selection')
    end
    redirect_to @qualys_config
  end

  def common_breadcrumb
    add_home_to_breadcrumb
    add_breadcrumb t('qualys_configs.section_title'), :qualys_configs_url
  end

  def new_data
    common_breadcrumb
    add_breadcrumb t('qualys_configs.actions.create')
    @app_section = make_section_header(
      title: t('qualys_configs.actions.create'),
      actions: [QualysConfigsHeaders.new.action(:back, :qualys_configs)]
    )
  end

  def edit_data
    common_breadcrumb
    add_breadcrumb @qualys_config.name, qualys_config_path(@qualys_config)
    add_breadcrumb t('qualys_configs.actions.edit')
    @app_section = make_section_header(
      title: t('qualys_configs.pages.edit', qualys_config: @qualys_config.name),
      actions: [QualysConfigsHeaders.new.action(:back, qualys_config_path(@qualys_config))]
    )
  end

  def qualys_config_params
    params.require(:qualys_config).permit(policy(QualysConfig).permitted_attributes)
  end

  def authorize!
    authorize(QualysConfig)
  end

  def authorize_qualys_config!
    authorize(@qualys_config)
  end

  def set_qualys_config
    id = params[:id] || params[:qualys_config_id]
    handle_unscoped { @qualys_config = policy_scope(QualysConfig).find(id) }
  end

  # UPDATE
  def update_wa_scans(reference = nil, options = {}, only: false, force: false)
    perform_notify_redirect do
      Importers::Qualys::Wa::ScansUpdateJob.perform_later(
        current_user.id, @qualys_config.id, reference, options,
        only_thumbnail: only, force_thumbnail: force
      )
    end
  end

  def update_vm_scans(reference = nil, options = {})
    perform_notify_redirect do
      Importers::Qualys::Vm::ScansUpdateJob.perform_later(
        current_user.id, @qualys_config.id, reference, options
      )
    end
  end

  def import_wa_scans(opts)
    perform_notify_redirect do
      Importers::Qualys::Wa::ScansImportJob.perform_later(
        current_user.id, @qualys_config.id, opts
      )
    end
  end

  def import_vm_scans(opts)
    perform_notify_redirect do
      Importers::Qualys::Vm::ScansImportJob.perform_later(
        current_user.id, @qualys_config.id, opts
      )
    end
  end

  def perform_notify_redirect
    yield
    notify_and_redirect(SETTINGS_IMPORT_SCANS)
  end

  # HEADERS
  def set_collection_section_header
    @headers = QualysConfigsHeaders.new
    @app_section = make_section_header(
      title: t('qualys_configs.section_title'),
      actions: [
        @headers.action(:create, nil),
        QualysVmClientsHeaders.new.action(:list, nil),
        QualysWaClientsHeaders.new.action(:list, nil)
      ]
    )
  end

  def set_member_section_header
    qualys_configs_h = QualysConfigsHeaders.new
    @app_section = make_section_header(
      title: @qualys_config.name,
      actions: [qualys_configs_h.action(:edit, @qualys_config)],
      other_actions: [qualys_configs_h.action(:destroy, @qualys_config)]
    )
  end

  def notify_and_redirect(translation_key)
    redirect_to @qualys_config, notice: t(translation_key)
  end
end
