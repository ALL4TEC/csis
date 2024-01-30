# frozen_string_literal: true

require 'whois-parser'

class ReportsController < ApplicationController
  SET_REPORT_ACTIONS = %i[show edit update destroy regenerate_scoring restore notify
                          auto_aggregate].freeze
  before_action :authenticate_user!
  before_action :authorize!, only: %i[index new create]
  before_action :set_whodunnit
  before_action :set_project, only: %i[index new create]
  before_action :set_report, only: SET_REPORT_ACTIONS
  before_action :authorize_report!, only: SET_REPORT_ACTIONS
  before_action :set_reports, only: %i[all]
  before_action :set_scans, only: %i[new edit]
  before_action :set_create_section_header, only: %i[new create]
  before_action :set_member_section_header, only: %i[show]
  before_action :set_edit_section_header, only: %i[edit update]
  before_action :set_collection_section_header, only: %i[index]

  EDITED_AT_DESC = 'edited_at desc'
  REPORTS_PAGES_PROJECT = 'reports.pages.project'
  AGGREGATES_ACTIONS_CREATE = 'aggregates.actions.create'

  def initialize
    models = self.class.name.delete_suffix('Controller')
    @model_u = models.singularize.underscore
    # @models_u = models.underscore
    @clazz = instance_eval(models.singularize)
    @param_name = @model_u.to_sym # ScanReport/PentestReport
    super
  end

  # Rails/LexicallyScopedActionFilter
  def index
    report_policy = ReportPolicy::Scope.new(current_user, Report)
    reports = @project.reports.includes(report_policy.list_includes).order(EDITED_AT_DESC)
    @q_base = reports.with_discarded
    @q = @q_base.trashed.ransack(params[:q])
    @trashed = @q.result.page(params[:page]).per(params[:per_page])

    @q = @q_base.kept.ransack(params[:q])
    @reports = @q.result.page(params[:page]).per(params[:per_page])
  end

  def show
    common_breadcrumb(@report.project)
    add_breadcrumb @report.title
  end

  def new
    common_breadcrumb(@project)
    add_breadcrumb t('reports.actions.create')
    @report = @clazz.new(staff: current_user, project: @project)
  end

  def edit
    common_breadcrumb(@report.project)
    add_breadcrumb @report.title, @report
    add_breadcrumb "#{t('reports.actions.edit')} #{@report.title}"
  end

  def create
    ActiveRecord::Base.transaction do
      permitted_params = report_params(:create)
      # We do not use params used for imports here
      init_report(permitted_params.except(:report_action_import))
      handle_imported(permitted_params.slice(:report_action_import))
      vm_occurrences, wa_occurrences = select_occurrences(permitted_params)
      # Base report, id is stored at creation for trace only, as it is not used when updating
      # By default, base report is project previous one.
      base_report = nil
      base_report = Report.find(@report.base_report_id) if @report.base_report_id.present?
      if [PentestReport, ScanReport].any? { |clazz| @report.is_a?(clazz) }
        ReportService.handle_occurrences(@report, base_report, vm_occurrences,
          wa_occurrences)
      end
    end
    handle_tools if @report.is_a?(PentestReport)
    redirect_to @report
  rescue ActiveRecord::RecordInvalid
    common_breadcrumb(@project)
    if @report.is_a?(PentestReport)
      add_breadcrumb t('reports.actions.create')
    else
      add_breadcrumb t(AGGREGATES_ACTIONS_CREATE)
      set_scans
    end
    render 'new'
  end

  # POST /reports/:id/notify
  def notify
    if @report.is_a?(ScanReport) && @report.project.auto_generate?
      @report.contacts.each do |contact|
        # Pas de mail chiffré car pas de détails sur les occurrences
        UserMailer.exceeding_severity_threshold_notification(contact, @report).deliver_later
      end
    end
    redirect_to @report, notice: t('reports.notices.mailed')
  end

  # /reports
  def all
    add_home_to_breadcrumb
    add_breadcrumb t('reports.section_title'), :reports_url
    @app_section = make_section_header(title: t('reports.section_subtitle'))
    @q_base = staff_signed_in? ? @reports.with_discarded : @reports
    if staff_signed_in?
      @q = @q_base.trashed.order(EDITED_AT_DESC).ransack params[:q]
      @trashed = @q.result.page(params[:page]).per(params[:per_page])
    end
    @q = @q_base.ransack params[:q]
    @q.sorts = ['meta_state asc', EDITED_AT_DESC] if @q.sorts.empty?
    @reports = @q.result.page(params[:page]).per(params[:per_page])

    render 'index'
  end

  # /project/{project_id}/reports
  def update
    permitted_params = report_params(:update)
    handle_tools if @report.is_a?(PentestReport)

    if @report.update(permitted_params.except(:report_action_import))
      handle_imported(permitted_params.slice(:report_action_import))
      if @report.project.auto_aggregate? && @report.aggregates.blank?
        ReportService.auto_aggregate_occurrences(@report)
      end
      redirect_to @report
    else
      common_breadcrumb(@report.project)
      title = @clazz.find(@report.id).title
      add_breadcrumb title, @report
      add_breadcrumb "#{t('reports.actions.edit')} #{title}"
      set_scans
      render 'edit'
    end
  end

  # Update Scoring VM et WAS
  def regenerate_scoring
    @report.regenerate_scoring
    redirect_to @report, notice: t('projects.labels.scoring')
  end

  def destroy
    project = @report.project
    @report.discard
    redirect_to project_reports_path(project)
  end

  def restore
    @report.undiscard
    redirect_to @report, notice: t('reports.notices.restored', report: @report.title)
  end

  # Auto aggregate occurrences
  def auto_aggregate
    mixing = params[:mixing] != 'false'
    ReportService.auto_aggregate_occurrences(@report, nil, nil, mixing)
    redirect_to report_aggregates_path(@report), notice: t('reports.notices.auto_aggregated')
  end

  private

  def authorize!
    authorize(@clazz)
  end

  def authorize_report!
    authorize(@report)
  end

  def report_params(action_sym)
    params.require(@param_name).permit(policy(@clazz).send(:"permitted_#{action_sym}_attributes"))
  end

  def common_breadcrumb(project)
    add_home_to_breadcrumb
    add_breadcrumb t('projects.section_title'), :projects_url
    add_breadcrumb project.name, project_path(project.id)
    add_breadcrumb t('models.reports'), project_reports_path(project.id)
  end

  def set_project
    store_request_referer(projects_path)
    handle_unscoped { @project = policy_scope(Project).find(params[:project_id]) }
  end

  def set_report
    store_request_referer(projects_path)
    handle_unscoped do
      clazz = Report.with_discarded.find(params[:id]).class
      report_policy = Pundit::PolicyFinder.new(clazz).scope.new(current_user, clazz)
      scope = params[:action].in?(%w[trashed restore]) ? 'trashed' : 'all'
      @report = report_policy.resolve.includes(report_policy.send(:"#{params[:action]}_includes"))
                             .send(scope).find(params[:id])
    end
  end

  def set_reports
    store_request_referer(dashboard_path)
    handle_unscoped do
      report_policy = ReportPolicy::Scope.new(current_user, Report)
      @reports = report_policy.resolve.includes(report_policy.all_includes)
    end
  end

  def set_scans
    vm_scans_policy = VmScanPolicy::Scope.new(current_user, VmScan)
    wa_scans_policy = WaScanPolicy::Scope.new(current_user, WaScan)
    @vm_scans = vm_scans_policy.resolve.includes(vm_scans_policy.list_includes)
    @wa_scans = wa_scans_policy.resolve.includes(wa_scans_policy.list_includes)
  end

  def set_create_section_header
    @app_section = make_section_header(
      title: t('reports.pages.create'),
      subtitle: t(REPORTS_PAGES_PROJECT, project: @project, client: @project.client),
      actions: [ProjectsHeaders.new.action(:back, project_reports_path(@project))]
    )
  end

  def set_edit_section_header
    clazz = @report.class
    @app_section = make_section_header(
      title: t('reports.pages.edit', report: @report),
      subtitle: t(REPORTS_PAGES_PROJECT, project: @report.project,
        client: @report.project.client),
      actions: ["#{clazz}sHeaders".constantize.new.action(:back, @report)]
    )
  end

  def set_member_section_header
    clazz = @report.type
    reports_headers = "#{clazz}sHeaders".constantize.new
    headers = policy_headers(clazz, :member).filter
    @app_section = make_section_header(
      title: t('reports.pages.title', report: @report.title,
        date: @report.edited_at.strftime('%d/%m/%y')),
      subtitle: t(REPORTS_PAGES_PROJECT, project: @report.project,
        client: @report.project.client),
      scopes: reports_headers.tabs(headers[:tabs], @report),
      actions: reports_headers.actions(headers[:actions], @report),
      other_actions: reports_headers.actions(headers[:other_actions], @report)
    )
  end

  def set_collection_section_header
    common_breadcrumb(@project)
    projects_headers = ProjectsHeaders.new
    headers = policy_headers(
      :project, :report, nil, ProjectPolicy.new(current_user, @project)
    ).filter

    @app_section = make_section_header(
      title: @project.name,
      subtitle: @project.client,
      scopes: projects_headers.tabs(headers[:tabs], @project),
      actions: projects_headers.actions(headers[:actions], @project),
      other_actions: projects_headers.actions(headers[:other_actions], @project)
    )
  end

  def init_report(permitted_params)
    permitted_params[:project] = @project
    permitted_params[:staff] = current_user
    @report = @clazz.new(permitted_params)
    @report.save!
  end

  def select_occurrences(permitted_params)
    vm_scan_ids = permitted_params[:vm_scan_ids] ? permitted_params[:vm_scan_ids].uniq : []
    wa_scan_ids = permitted_params[:wa_scan_ids] ? permitted_params[:wa_scan_ids].uniq : []
    vm_occurrences = select_vm_occurrences(vm_scan_ids.compact_blank)
    wa_occurrences = OccurrenceService.select_wa_occurrences(wa_scan_ids.compact_blank)
    [vm_occurrences, wa_occurrences]
  end

  def update_scans
    ReportVmScan.where(report: @report, vm_scan_id: params[@param_name][:vm_scan_ids])
                .find_each do |report_vm_scan|
      report_vm_scan.update(targets: Target.where(id: params[@param_name][:target_ids]) &
        report_vm_scan.vm_scan.targets)
    end
    ReportWaScan.where(report: @report, wa_scan_id: params[@param_name][:wa_scan_ids])
                .find_each do |report_wa_scan|
      report_wa_scan.update(web_app_url: params[report_wa_scan.wa_scan_id.to_s])
    end
  end

  def select_vm_occurrences(vm_scan_ids)
    selected_targets = []
    if @clazz == ScanReport
      targets = params[@param_name][:target_ids] ? params[@param_name][:target_ids].uniq : []
      targets.shift
      selected_targets = Target.find(targets)
    end
    OccurrenceService.select_vm_occurrences(@clazz, vm_scan_ids, selected_targets)
  end

  def handle_imported(permitted_params)
    @report.is_a?(ActionPlanReport) ? handle_actions_import(permitted_params) : update_scans
  end
end
