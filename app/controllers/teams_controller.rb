# frozen_string_literal: true

class TeamsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize!, only: %i[index new create show]
  before_action :set_whodunnit
  before_action :set_team, only: %i[show edit update destroy]
  before_action :set_trashed_team, only: %i[restore]
  before_action :authorize_team!, only: %i[edit update destroy restore]
  before_action :set_teams, only: %i[index]
  before_action :set_collection_section_header, only: %i[index]
  before_action :set_member_section_header, only: %i[show]

  include MfaController

  def index
    common_breadcrumb
    @q_base = @teams
    @q = @q_base.ransack params[:q]
    @q.sorts = ['name asc', 'created_at desc']
    @teams = @q.result.page(params[:page]).per(params[:per_page])
  end

  def show
    common_breadcrumb
    add_breadcrumb @team.name
  end

  def new
    @team = Team.new
    @team.staffs << current_user unless current_user.super_admin?
    new_data
  end

  def edit
    edit_data
  end

  def create
    @team = Team.new(team_params)

    @team.staffs << current_user unless current_user.in?(@team.staffs) || current_user.super_admin?

    if @team.save
      redirect_to @team
    else
      new_data
      render 'new'
    end
  end

  def update
    if @team.update(team_params)
      redirect_to @team
    else
      edit_data
      render 'edit'
    end
  end

  def restore
    @team.undiscard
    redirect_to teams_path, notice: t('teams.notices.restored')
  end

  def destroy
    if @team.discard
      flash[:notice] = t('teams.notices.deletion_success')
    else
      flash[:alert] = t('teams.notices.deletion_failure')
    end
    redirect_to teams_path
  end

  private

  def common_breadcrumb
    add_home_to_breadcrumb
    add_breadcrumb t('teams.section_title'), :teams_url
  end

  def new_data
    common_breadcrumb
    add_breadcrumb t('teams.actions.create')
    @app_section = make_section_header(
      title: t('teams.actions.create'),
      actions: [TeamsHeaders.new.action(:back, back_in_history)]
    )
  end

  def edit_data
    common_breadcrumb
    add_breadcrumb @team.name, team_path(@team)
    add_breadcrumb t('teams.actions.edit')
    @app_section = make_section_header(
      title: t('teams.pages.edit', team: @team.name),
      actions: [TeamsHeaders.new.action(:back, back_in_history)]
    )
  end

  def authorize!
    authorize(Team)
  end

  def authorize_team!
    authorize(@team)
  end

  def team_params
    params.require(:team).permit(policy(Team).permitted_attributes)
  end

  def set_team
    store_request_referer(teams_path)
    handle_unscoped { @team = policy_scope(Team).find(params[:id]) }
  end

  def set_trashed_team
    store_request_referer(teams_path)
    handle_unscoped { @team = policy_scope(Team).trashed.find(params[:id]) }
  end

  def set_teams
    team_policy = TeamPolicy::Scope.new(current_user, Team)
    @teams = team_policy.resolve.includes(team_policy.list_includes)
  end

  def set_collection_section_header
    @headers = TeamsHeaders.new
    @app_section = make_section_header(
      title: t('teams.section_title'),
      actions: @headers.actions(policy_headers(:team, :collection).actions, nil)
    )
  end

  def set_member_section_header
    teams_headers = TeamsHeaders.new
    headers = policy_headers(:team, :member, @team)
    @app_section = make_section_header(
      title: @team.name,
      actions: teams_headers.actions(headers.actions, @team),
      other_actions: teams_headers.actions(headers.other_actions, @team)
    )
  end
end
