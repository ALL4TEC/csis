# frozen_string_literal: true

class ActionPlanReportsController < ReportsController
  before_action :action_plan_enabled
  before_action :set_action_plan_report, only: %i[new_appendix index action_plans]
  before_action :set_aggregate_section_header, only: %i[new_appendix index action_plans]

  DEFAULT_SORT = ['meta_state asc', 'aggregate_severity desc', 'created_at desc'].freeze

  # <tt>GET /reports/:report_id/actions</tt>
  def action_plans
    aggregate_breadcrumb(@report)
    @actions = filtered_list(@report.actions, DEFAULT_SORT)
    render 'reports/actions'
  end

  private

  def set_action_plan_report
    set_report
  end

  def action_plan_enabled
    Rails.application.config.action_plan_enabled
  end

  def aggregate_breadcrumb(report)
    add_home_to_breadcrumb
    add_breadcrumb t('projects.section_title'), :projects_url
    add_breadcrumb report.project.name, project_path(report.project_id)
    add_breadcrumb t('models.reports'), project_reports_path(report.project_id)
    add_breadcrumb report.title, report
  end

  def set_aggregate_section_header
    clazz = @report.type
    reports_headers = "#{clazz}sHeaders".constantize.new
    headers = policy_headers(clazz, :member).filter

    @app_section = make_section_header(
      title: report_title(@report),
      subtitle: report_subtitle(@report),
      scopes: reports_headers.tabs(headers[:tabs], @report),
      actions: [reports_headers.action(:back, report_aggregates_path(@report))]
    )
  end

  def report_title(report)
    t('reports.pages.title', report: report.title, date: report.edited_at.strftime('%d/%m/%y'))
  end

  def report_subtitle(report)
    t('reports.pages.project', project: report.project, client: report.project.client)
  end

  def handle_actions_import(permitted)
    # Create report_action_import from params
    handle_unscoped { raise ActiveRecord::RecordNotFound } unless permitted.permitted?

    report_action_import_params = permitted[:report_action_import]
    return if report_action_import_params.blank?

    action_import = ActionImport.create!(
      importer: current_user, status: :scheduled, import_type: :csv
    )
    report_action_import = ReportActionImport.create!(
      report: @report,
      action_import: action_import,
      document: report_action_import_params[:document]
    )
    Importers::ActionsImportJob.perform_later(report_action_import)
  end
end
