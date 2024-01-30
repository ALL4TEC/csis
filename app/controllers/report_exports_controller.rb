# frozen_string_literal: true

class ReportExportsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize!
  before_action :set_whodunnit
  before_action :set_report, only: %i[index create]
  before_action :set_report_export, only: %i[destroy]
  before_action :common_breadcrumb, only: %i[index]

  def index
    clazz = @report.type
    reports_headers = "#{clazz}sHeaders".constantize.new
    select_header = clazz == 'ActionPlanReport' ? clazz : 'ReportExport'
    headers = policy_headers(select_header, :member).filter

    @app_section = make_section_header(
      title: t('reports.pages.title', report: @report.title,
        date: @report.edited_at.strftime('%d/%m/%y')),
      subtitle: t('reports.pages.project', project: @report.project,
        client: @report.project.client),
      actions: reports_headers.actions(headers[:actions], @report),
      other_actions: reports_headers.actions(headers[:other_actions], @report),
      scopes: reports_headers.tabs(headers[:tabs], @report)
    )
    @q_base = @report.exports.includes(:exporter)
    @q = @q_base.ransack params[:q]
    @exports = @q.result.page(params[:page]).per(params[:per_page])
  end

  def create
    exporter = @report.signatory || current_user
    report_export = ReportExport.create!(report: @report, exporter: exporter, status: :scheduled)
    respond_to do |format|
      format.pdf do
        archi = params[:archi] != 'false'
        histo = params[:histo] != 'false'
        if @report.type.in?(Report::ALL_CLAZZS)
          send(:"handle_#{@report.type.underscore}", report_export, archi, histo)
        else
          flash[:notice] = t('exports.notices.non_generating')
        end
      end
      format.xlsx { handle_xlsx_report_aggregates(report_export) }
    end
    redirect_to report_exports_path(@report)
  end

  def destroy
    @report = @export.report
    @export.destroy
    redirect_to report_exports_path(@report), notice: t('exports.notices.deleted')
  end

  private

  def authorize!
    authorize(ReportExport)
  end

  def common_breadcrumb
    add_home_to_breadcrumb
    add_breadcrumb t('projects.section_title'), :projects_url
    add_breadcrumb @report.project.name, project_path(@report.project_id)
    add_breadcrumb t('models.reports'), project_reports_path(@report.project_id)
    add_breadcrumb @report.title, @report
    add_breadcrumb t('models.exports')
  end

  def set_report
    store_request_referer(projects_path)
    handle_unscoped { @report = policy_scope(Report).find(params[:report_id]) }
  end

  def set_report_export
    store_request_referer(projects_path)
    handle_unscoped { @export = policy_scope(ReportExport).find(params[:id]) }
  end

  ### Report generators handlers methods
  # TODO: Move in dedicated handler class ?
  # After refactoring to API
  def handle_scan_report(report_export, archi, histo)
    ::Generators::ScanReportGeneratorJob.perform_later(report_export.id, archi, histo)
    flash.now[:notice] = t('exports.notices.generating')
  end

  def handle_action_plan_report(report_export, _archi, _histo)
    return if Rails.application.config.action_plan_enabled

    ::Generators::ScanReportGeneratorJob.perform_later(report_export.id, false, false)
    flash.now[:notice] = t('exports.notices.generating')
  end

  def handle_pentest_report(report_export, _archi, _histo)
    return if Rails.application.config.pentest_enabled

    ::Generators::PentestReportGeneratorJob.perform_later(report_export.id)
    flash.now[:notice] = t('exports.notices.generating')
  end

  def handle_xlsx_report_aggregates(report_export)
    ::Generators::XlsxReportAggregatesGeneratorJob.perform_later(report_export.id)
    flash.now[:notice] = t('exports.notices.generating')
  end
end
