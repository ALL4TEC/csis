# frozen_string_literal: true

class ReportScanImportsController < ApplicationController
  include ReportCommon

  IMPORTERS_MAP = {
    burp: Importers::BurpIssuesImportJob,
    nessus: Importers::NessusImportJob,
    with_secure: Importers::WithSecureImportJob,
    zaproxy: Importers::ZaproxyImportJob
  }.freeze

  before_action :authenticate_user!
  before_action :authorize!, except: %i[destroy]
  before_action :set_whodunnit
  before_action :set_report, only: %i[index new create]
  before_action :set_scan_import, only: %i[destroy]
  before_action :authorize_scan_import!, only: %i[destroy]
  before_action :common_breadcrumb, only: %i[index new]

  def index
    build_app_section(:import_scan)
    @q_base = @report.scan_imports.includes(:importer)
    @q = @q_base.ransack params[:q]
    @scan_imports = @q.result.page(params[:page]).per(params[:per_page])
  end

  def new
    new_data
  end

  def create
    permitted = params.require(:scan_import)
                      .permit(
                        :import_type,
                        report_scan_import_attributes: %i[
                          document
                          auto_aggregate
                          auto_aggregate_mixing
                          scan_name
                        ]
                      )
    handle_unscoped { raise ActiveRecord::RecordNotFound } unless permitted.permitted?

    ActiveRecord::Base.transaction do
      scan_import = ScanImport.create!(
        importer: current_user, status: :scheduled, import_type: permitted[:import_type].to_sym
      )
      report_scan_import_attributes = permitted[:report_scan_import_attributes]
      report_scan_import = ReportScanImport.create!(
        report: @report, scan_import: scan_import,
        auto_aggregate: report_scan_import_attributes[:auto_aggregate],
        auto_aggregate_mixing: report_scan_import_attributes[:auto_aggregate_mixing],
        scan_name: report_scan_import_attributes[:scan_name],
        document: report_scan_import_attributes[:document]
      )
      import_type = scan_import.import_type.to_sym
      if IMPORTERS_MAP.key?(import_type)
        IMPORTERS_MAP[import_type].perform_later(report_scan_import)
        redirect_to report_scan_imports_path(@report), notice: t('imports.notices.processing')
      else
        handle_unscoped { raise ActiveRecord::RecordNotFound }
      end
    rescue ActiveRecord::RecordInvalid
      new_data
      @scan_import = scan_import
      render 'new'
    end
  end

  def destroy
    @report = @scan_import.report_scan_import.report
    if [@scan_import.wa_scans, @scan_import.vm_scans].any?(&:present?)
      DestructorJob.perform_later(current_user, @scan_import)
    else
      @scan_import.destroy!
    end
    redirect_to report_scan_imports_path(@report), notice: t('imports.notices.deleted')
  end

  private

  def common_breadcrumb
    add_home_to_breadcrumb
    add_breadcrumb t('projects.section_title'), :projects_url
    add_breadcrumb @report.project.name, project_path(@report.project_id)
    add_breadcrumb t('models.reports'), project_reports_path(@report.project_id)
    add_breadcrumb @report.title, @report
    add_breadcrumb t('models.imports'), report_scan_imports_path(@report)
  end

  def set_report
    store_request_referer(projects_path)
    handle_unscoped { @report = policy_scope(Report).find(params[:report_id]) }
  end

  def set_scan_import
    store_request_referer(projects_path)
    handle_unscoped { @scan_import = policy_scope(ScanImport).find(params[:id]) }
  end

  def new_data
    add_breadcrumb t('imports.actions.create')
    @app_section = make_section_header(
      title: t('imports.actions.create'),
      actions: [ScanReportsHeaders.new.action(:back, back_in_history)]
    )
    @scan_import = ScanImport.new
    @scan_import.build_report_scan_import
  end

  def authorize!
    authorize(ReportScanImport)
  end

  def authorize_scan_import!
    authorize(@scan_import)
  end
end
