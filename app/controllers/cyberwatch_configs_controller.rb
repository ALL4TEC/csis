# frozen_string_literal: true

class CyberwatchConfigsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize!, except: %i[activate deactivate destroy]
  before_action :set_whodunnit
  before_action :set_cyberwatch_config, only: %i[show edit update destroy vulnerabilities_import
                                                 assets_import scans_import scans_update
                                                 scan_delete activate deactivate ping]
  before_action :authorize_cyberwatch_config!, only: %i[activate deactivate destroy]
  before_action :set_collection_section_header, only: %i[index]
  before_action :set_member_section_header, only: %i[show]

  SETTINGS_IMPORT_SCANS = 'settings.import_scans'

  def index
    common_breadcrumb
    @q_base = policy_scope(CyberwatchConfig).includes(:teams)
    @q = @q_base.ransack params[:q]
    @q.sorts = ['name asc', 'created_at desc'] if @q.sorts.blank?
    @cbw_configs = @q.result.page(params[:page]).per(params[:per_page])
  end

  def show
    common_breadcrumb
    add_breadcrumb @cbw_config.name
  end

  def new
    @cbw_config = CyberwatchConfig.new
    new_data
  end

  def edit
    edit_data
  end

  def create
    @cbw_config = CyberwatchConfig.new(cyberwatch_config_params)
    if @cbw_config.save
      redirect_to @cbw_config
    else
      new_data
      render 'new'
    end
  end

  def update
    if @cbw_config.update(cyberwatch_config_params)
      redirect_to @cbw_config
    else
      edit_data
      render 'edit'
    end
  end

  def activate
    @cbw_config.undiscard
    redirect_to cyberwatch_configs_path
  end

  def deactivate
    @cbw_config.discard
    redirect_to cyberwatch_configs_path
  end

  def destroy
    if @cbw_config.destroy
      flash[:notice] = t('cyberwatch_configs.notices.deletion_success')
    else
      flash[:alert] = t('cyberwatch_configs.notices.deletion_failure')
    end
    redirect_to cyberwatch_configs_path
  end

  # Imports
  def scans_import
    handle_import(:vm) { |opts| import_vm_scans(opts) }
  end

  # Updates
  # def scans_update
  #   handle_import(:vm) { |opts| update_vm_scans(params[:reference], opts) }
  # end

  # Import vulnerabilities
  def vulnerabilities_import
    Importers::Cyberwatch::VulnerabilitiesImportJob.perform_later(
      current_user.id, @cbw_config.id, last: params[:last_only].present?
    )
    notify_and_redirect('settings.import_vulnerabilities')
  end

  # Import assets
  def assets_import
    Importers::Cyberwatch::AssetsImportJob.perform_later(
      current_user.id, @cbw_config.id
    )
    notify_and_redirect('settings.import_assets')
  end

  # Scan deletion
  def scan_delete
    delete_scan('vm')
  end

  # Ping
  def ping
    response = Cyberwatch::Request.ping(@cbw_config)
    key = response.code == '200' ? :notice : :alert
    flash[key] = "Ping response : #{response.code} #{response.message}"
    redirect_to @cbw_config
  end

  private

  def handle_import(_kind)
    permitted = params.require(:cyberwatch_config).permit(
      policy(CyberwatchConfig).permitted_scans_attributes
    )
    if permitted.permitted?
      opts = CyberwatchConfigsParamsHandler.call(permitted, params[:action])
      yield opts
    else
      notify_and_redirect(FORM_ERROR)
    end
  end

  def delete_scan(kind)
    if params[:scan_id].present?
      begin
        scan = @cbw_config.send(:"#{kind}_scans").recently_launched.find(params[:scan_id])
        scan.destroy
        flash.now[:notice] = t('settings.notices.deleted')
      rescue ActiveRecord::RecordNotFound
        flash.now[:alert] = t('settings.notices.wrong_value')
      end
    else
      flash[:alert] = t('settings.notices.no_selection')
    end
    redirect_to @cbw_config
  end

  def common_breadcrumb
    add_home_to_breadcrumb
    add_breadcrumb t('cyberwatch_configs.section_title'), :cyberwatch_configs_url
  end

  def new_data
    common_breadcrumb
    add_breadcrumb t('cyberwatch_configs.actions.create')
    @app_section = make_section_header(
      title: t('cyberwatch_configs.actions.create'),
      actions: [CyberwatchConfigsHeaders.new.action(:back, :cyberwatch_configs)]
    )
  end

  def edit_data
    common_breadcrumb
    add_breadcrumb @cbw_config.name, cyberwatch_config_path(@cbw_config)
    add_breadcrumb t('cyberwatch_configs.actions.edit')
    @app_section = make_section_header(
      title: t('cyberwatch_configs.pages.edit', cyberwatch_config: @cbw_config.name),
      actions: [CyberwatchConfigsHeaders.new.action(:back, cyberwatch_config_path(@cbw_config))]
    )
  end

  def cyberwatch_config_params
    params.require(:cyberwatch_config).permit(policy(CyberwatchConfig).permitted_attributes)
  end

  def authorize!
    authorize(CyberwatchConfig)
  end

  def authorize_cyberwatch_config!
    authorize(@cbw_config)
  end

  def set_cyberwatch_config
    id = params[:id] || params[:cyberwatch_config_id]
    handle_unscoped { @cbw_config = policy_scope(CyberwatchConfig).find(id) }
  end

  def update_vm_scans(reference = nil, options = {})
    perform_notify_redirect do
      Importers::Cyberwatch::Vm::ScansUpdateJob.perform_later(
        current_user.id, @cbw_config.id, reference, options
      )
    end
  end

  def import_vm_scans(opts)
    perform_notify_redirect do
      Importers::Cyberwatch::Vm::ScansImportJob.perform_later(
        current_user.id, @cbw_config.id, opts
      )
    end
  end

  def perform_notify_redirect
    yield
    notify_and_redirect(SETTINGS_IMPORT_SCANS)
  end

  # HEADERS
  def set_collection_section_header
    @headers = CyberwatchConfigsHeaders.new
    @app_section = make_section_header(
      title: t('cyberwatch_configs.section_title'),
      actions: [
        @headers.action(:create, nil)
      ]
    )
  end

  def set_member_section_header
    cyberwatch_configs_h = CyberwatchConfigsHeaders.new
    @app_section = make_section_header(
      title: @cbw_config.name,
      actions: [cyberwatch_configs_h.action(:edit, @cbw_config)],
      other_actions: [cyberwatch_configs_h.action(:destroy, @cbw_config)]
    )
  end

  def notify_and_redirect(translation_key)
    redirect_to @cbw_config, notice: t(translation_key)
  end
end
