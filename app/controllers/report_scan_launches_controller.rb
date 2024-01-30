# frozen_string_literal: true

class ReportScanLaunchesController < ApplicationController
  include ReportCommon
  before_action :authenticate_user!
  before_action :authorize!, except: %i[destroy import]
  before_action :set_whodunnit
  before_action :set_report, only: %i[index new zaproxy]
  before_action :build_scan_launch, only: %i[zaproxy]
  before_action :set_scan_launch, only: %i[destroy import]
  before_action :authorize_scan_launch!, only: %i[destroy import]
  before_action :common_breadcrumb, only: %i[index new]

  # GET /reports/:id/scan_launches
  def index
    build_app_section(:launch_scan)
    @q_base = @report.scan_launches.includes(scan_configuration: :launcher)
    @q = @q_base.ransack params[:q]
    @scan_launches = @q.result.page(params[:page]).per(params[:per_page])
  end

  # GET /reports/:id/scan_launches/new
  def new
    new_data
  end

  # POST /reports/:id/scan_launches/zaproxy
  # Scb enabled check is made at boot in config, can be deactivated if not present in SCB_SCANNERS
  def zaproxy
    if @scan_launch.save
      Launchers::Scb::ZaproxyScanJob.perform_later(@scan_launch)
      redirect_to report_scan_launches_path(@report), notice: t('scan_launches.notices.processing')
    else
      common_breadcrumb
      new_data
      render 'new'
    end
  end

  # POST /scan_launches/:id/import
  def import
    ReportScanLaunchService.launch_import(@scan_launch, current_user)
    redirect_to report_scan_imports_path(@scan_launch.report),
      notice: t('imports.notices.processing')
  end

  # DELETE /scan_launches/:id
  def destroy
    @report = @scan_launch.report
    @scan_launch.destroy!
    redirect_to report_scan_launches_path(@report), notice: t('scan_launches.notices.deleted')
  end

  private

  def common_breadcrumb
    add_home_to_breadcrumb
    add_breadcrumb t('projects.section_title'), :projects_url
    add_breadcrumb @report.project.name, project_path(@report.project_id)
    add_breadcrumb t('models.reports'), project_reports_path(@report.project_id)
    add_breadcrumb @report.title, @report
    add_breadcrumb t('models.scan_launches'), report_scan_launches_path(@report)
  end

  def set_report
    handle_unscoped { @report = policy_scope(Report).find(params[:report_id]) }
  end

  def build_scan_launch
    handle_unscoped do
      @scan_launch = ScanConfigurationParamsHandler.call(
        params, :scan_launch, policy(:scan_launch), @report
      )
    end
  end

  def set_scan_launch
    handle_unscoped { @scan_launch = policy_scope(ScanLaunch).find(params[:id]) }
  end

  def new_data
    title = t('scan_launches.actions.create')
    add_breadcrumb title
    @app_section = make_section_header(
      title: title,
      actions: [ScanReportsHeaders.new.action(:back, back_in_history)]
    )
    init_scan_launch
  end

  def init_scan_launch
    @scan_launch ||= ScanLaunch.new
  end

  def authorize!
    authorize(ScanLaunch)
  end

  def authorize_scan_launch!
    authorize(@scan_launch)
  end
end
