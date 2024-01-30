# frozen_string_literal: true

class VulnerabilitiesImportsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize!, except: %i[destroy]
  before_action :set_whodunnit
  before_action :set_vulnerability_import, only: %i[destroy]
  before_action :common_breadcrumb, only: %i[index new]

  def index
    vuln_headers = VulnerabilitiesHeaders.new
    headers = policy_headers(:vulnerability, :collection).filter
    @app_section = make_section_header(
      title: t('vulnerabilities.section_title'),
      scopes: vuln_headers.tabs(headers[:tabs], Vulnerability),
      actions: vuln_headers.actions(headers[:actions], nil),
      filter_btn: true
    )
    @q_base = VulnerabilityImport.all.includes(:importer)
    @q = @q_base.ransack params[:q]
    @vuln_imports = @q.result.page(params[:page]).per(params[:per_page])
  end

  def new
    new_data
  end

  def create
    permitted = params.require(:vulnerability_import).permit(:import_type, :document)
    handle_unscoped { raise ActiveRecord::RecordNotFound } unless permitted.permitted?

    vuln_import = VulnerabilityImport.create!(
      importer: current_user, status: :scheduled, import_type: params[:import_type].to_i,
      document: permitted[:document]
    )
    case vuln_import.import_type.to_sym
    when :cve
      # CVE
      Importers::CveImportJob.perform_later(vuln_import)
    else
      handle_unscoped { raise ActiveRecord::RecordNotFound }
    end
    redirect_to vulnerabilities_path, notice: t('imports.notices.processing')
  end

  def destroy
    authorize(@vuln_import)
    @vuln_import.destroy!
    redirect_to vulnerabilities_path, notice: t('imports.notices.deleted')
  end

  private

  def authorize!
    authorize(VulnerabilityImport)
  end

  def common_breadcrumb
    add_home_to_breadcrumb
    add_breadcrumb t('vulnerabilities.section_title'), :vulnerabilities_url
  end

  def set_vulnerability_import
    store_request_referer(vulnerabilities_path)
    handle_unscoped { @vuln_import = policy_scope(VulnerabilityImport).find(params[:id]) }
  end

  def new_data
    add_breadcrumb t('imports.actions.create')
    @app_section = make_section_header(
      title: t('imports.actions.create'),
      actions: [VulnerabilitiesHeaders.new.action(:back, back_in_history)]
    )
    @vuln_import = VulnerabilityImport.new
  end
end
