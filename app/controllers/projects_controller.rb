# frozen_string_literal: true

class ProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize!, only: %i[index new create]
  before_action :set_whodunnit
  before_action :set_project, only: %i[show edit update destroy regenerate_scoring]
  before_action :set_trashed_project, only: %i[restore]
  before_action :authorize_project!, only: %i[show edit update destroy restore]
  before_action :set_projects, only: %i[index trashed regenerate_all_scoring]
  before_action :set_collection_section_header, only: %i[index trashed]
  before_action :set_member_section_header, only: %i[show]

  def index
    list_projects
  end

  def trashed
    list_projects
  end

  def show
    common_breadcrumb
    add_breadcrumb @project.name
  end

  def new
    @project = Project.new
    new_data
  end

  def edit
    edit_data
  end

  def create
    @project = Project.new(project_params)
    if @project.save
      @project.certificate.update_certificate
      redirect_to @project
    else
      new_data
      render 'new'
    end
  end

  def update
    if @project.update(project_params)
      @project.certificate.update_certificate
      redirect_to @project
    else
      edit_data
      render 'edit'
    end
  end

  def destroy
    @project.discard
    notice = t(
      'projects.notices.deleted_html',
      project: html_escape_once(@project.name),
      cancel: helpers.link_to(
        t('projects.actions.restore'),
        restore_project_path(@project),
        method: :put,
        data: {
          confirm: t(
            'projects.actions.restore_confirm',
            infos: html_escape_once(@project.name)
          )
        }
      )
    )
    redirect_to projects_path, notice: notice
  end

  def restore
    @project.undiscard
    redirect_to @project, notice: t('projects.notices.restored', project: @project.name)
  end

  # Update Scoring VM et WAS for one project
  def regenerate_scoring
    regen_scoring(@project.reports)
  end

  # Update Scoring VM et WAS for scoped reports
  def regenerate_all_scoring
    regen_scoring(@projects.flat_map(&:reports))
  end

  private

  def authorize!
    authorize(Project)
  end

  def authorize_project!
    authorize(@project)
  end

  def common_breadcrumb
    add_home_to_breadcrumb
    add_breadcrumb t('projects.section_title'), :projects_url
  end

  def list_projects
    common_breadcrumb
    add_breadcrumb t('scopes.trashed') unless caller_locations(1..1).first.label == 'index'
    @q_base = @projects
    @q = @q_base.ransack params[:q]
    @q.sorts = ['name asc']
    @projects = @q.result.page(params[:page]).per(params[:per_page])
  end

  def new_data
    common_breadcrumb
    add_breadcrumb t('projects.actions.create')
    @app_section = make_section_header(
      title: t('projects.actions.create'),
      subtitle: @project.client,
      actions: [ProjectsHeaders.new.action(:back, :projects)]
    )
  end

  def edit_data
    project = Project.find(@project.id)
    common_breadcrumb
    add_breadcrumb project.name, project_path(@project)
    add_breadcrumb "#{t('projects.actions.edit')} #{project.name}"
    @app_section = make_section_header(
      title: t('projects.pages.edit', project: project.name),
      subtitle: project.client,
      actions: [ProjectsHeaders.new.action(:back, project_path(@project))]
    )
  end

  def project_params
    params.require(:project).permit(policy(Project).permitted_attributes)
  end

  def regen_scoring(reports)
    reports.map(&:regenerate_scoring)
    flash[:notice] = t('projects.labels.scoring')
    redirect_back(fallback_location: root_path)
  end

  def set_project
    store_request_referer(projects_path)
    handle_unscoped { @project = policy_scope(Project).find(params[:id]) }
  end

  def set_projects
    store_request_referer(dashboard_path)
    handle_unscoped do
      project_policy = ProjectPolicy::Scope.new(current_user, Project)
      @projects = project_policy.resolve.includes(project_policy.list_includes)
    end
  end

  def set_trashed_project
    store_request_referer(projects_path)
    handle_unscoped { @project = policy_scope(Project).trashed.find(params[:id]) }
  end

  def set_collection_section_header
    @headers = ProjectsHeaders.new
    headers = policy_headers(:project, :collection).filter
    @app_section = make_section_header(
      title: t('projects.section_title'),
      actions: @headers.actions(headers[:actions], nil),
      other_actions: @headers.actions(headers[:other_actions], nil),
      scopes: @headers.tabs(headers[:tabs], @projects)
    )
    scope = params[:action] == 'trashed' ? 'trashed' : 'kept'
    @projects = @projects.send(scope)
  end

  def set_member_section_header
    @headers = ProjectsHeaders.new
    headers = policy_headers(:project, :member, @project).filter
    @app_section = make_section_header(
      title: @project.name,
      subtitle: @project.client,
      actions: @headers.actions(headers[:actions], @project),
      other_actions: @headers.actions(headers[:other_actions], @project),
      scopes: @headers.tabs(headers[:tabs], @project)
    )
  end
end
