# frozen_string_literal: true

class ScheduledScansController < ApplicationController
  ACTIONS_NEEDING_RECORD = %i[destroy activate deactivate].freeze
  before_action :authenticate_user!
  before_action :authorize!, except: ACTIONS_NEEDING_RECORD
  before_action :set_whodunnit
  before_action :set_project, only: %i[index new zaproxy]
  before_action :build_scheduled_scan, only: %i[zaproxy]
  before_action :set_scheduled_scan, only: ACTIONS_NEEDING_RECORD
  before_action :authorize_scheduled_scan!, only: ACTIONS_NEEDING_RECORD
  before_action :common_breadcrumb, only: %i[index new]

  # GET /projects/:id/scheduled_scans
  def index
    projects_headers = ProjectsHeaders.new
    headers = policy_headers(
      :scheduled_scan, :member, nil, ProjectPolicy.new(current_user, @project)
    ).filter
    @app_section = make_section_header(
      title: @project.name,
      subtitle: @project.client,
      scopes: projects_headers.tabs(headers[:tabs], @project),
      actions: projects_headers.actions(headers[:actions], @project),
      other_actions: projects_headers.actions(headers[:other_actions], @project),
      filter_btn: true
    )
    @q_base = @project.scheduled_scans.includes(scan_configuration: :launcher)
    @q = @q_base.ransack params[:q]
    @scheduled_scans = @q.result.page(params[:page]).per(params[:per_page])
  end

  # GET /projects/:id/scheduled_scans/new
  def new
    new_data
  end

  # POST /projects/:id/scheduled_scans/zaproxy
  # Scb enabled check is made at boot in config, can be deactivated if not present in SCB_SCANNERS
  def zaproxy
    if @scheduled_scan.save
      redirect_to project_scheduled_scans_path(@project),
        notice: t('scheduled_scans.notices.scheduled')
    else
      common_breadcrumb
      new_data
      render 'new'
    end
  end

  # PUT /scheduled_scans/:id/activate
  def activate
    project = @scheduled_scan.project
    @scheduled_scan.undiscard
    redirect_to project_scheduled_scans_path(project),
      notice: t('scheduled_scans.notices.activated')
  end

  # PUT /scheduled_scans/:id/deactivate
  def deactivate
    project = @scheduled_scan.project
    @scheduled_scan.discard
    redirect_to project_scheduled_scans_path(project),
      notice: t('scheduled_scans.notices.deactivated')
  end

  # DELETE /scheduled_scans/:id
  def destroy
    project = @scheduled_scan.project
    @scheduled_scan.destroy!
    redirect_to project_scheduled_scans_path(project),
      notice: t('scheduled_scans.notices.deleted')
  end

  private

  def common_breadcrumb
    add_home_to_breadcrumb
    add_breadcrumb t('projects.section_title'), :projects_url
    add_breadcrumb @project.name, project_path(@project)
    add_breadcrumb t('models.scheduled_scans'), project_scheduled_scans_path(@project)
  end

  def set_project
    handle_unscoped { @project = policy_scope(Project).find(params[:project_id]) }
  end

  def build_scheduled_scan
    handle_unscoped do
      @scheduled_scan = ScanConfigurationParamsHandler.call(
        params, :scheduled_scan, policy(:scheduled_scan), @project
      )
    end
  end

  def set_scheduled_scan
    handle_unscoped { @scheduled_scan = policy_scope(ScheduledScan).find(params[:id]) }
  end

  def new_data
    title = t('scheduled_scans.actions.create')
    add_breadcrumb title
    @app_section = make_section_header(
      title: title,
      actions: [HeadersHandler.new.action(:back, back_in_history)]
    )
    init_scheduled_scan
  end

  def init_scheduled_scan
    @scheduled_scan ||= ScheduledScan.new
  end

  def authorize!
    authorize(ScheduledScan)
  end

  def authorize_scheduled_scan!
    authorize(@scheduled_scan)
  end
end
