# frozen_string_literal: true

class TargetsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize!, only: %i[index new create]
  before_action :set_whodunnit
  before_action :set_asset, only: %i[index new create]
  before_action :set_target, only: %i[show edit update destroy]
  before_action :set_trashed_target, only: %i[restore]
  before_action :authorize_target!, only: %i[show edit update destroy restore]
  before_action :set_targets, only: %i[index trashed all]
  before_action :set_collection_section_header, only: %i[index trashed]
  before_action :set_member_section_header, only: %i[show]
  before_action :set_js_objects, only: %i[new edit]

  ### ENDPOINTS ###

  # <tt>GET /targets</tt>
  # Affichage de toutes les cibles
  def all
    add_home_to_breadcrumb
    add_breadcrumb t('targets.section_title'), :targets_url
    @headers = TargetsHeaders.new
    headers = policy_headers(:target, :collection).filter
    @app_section = make_section_header(
      title: t('targets.section_subtitle'),
      actions: @headers.actions(headers[:actions], nil)
    )
    @q_base = staff_signed_in? ? @targets.with_discarded : @targets
    if staff_signed_in?
      @q = @q_base.trashed.ransack params[:q]
      @trashed = @q.result.page(params[:page]).per(params[:per_page])
    end
    @q = @q_base.ransack params[:q]
    @targets = @q.result.page(params[:page]).per(params[:per_page])

    render 'index'
  end

  # <tt>GET /assets/:id/targets</tt>
  # Affichage des cibles pour un actif
  def index
    list_targets
  end

  # <tt>GET /assets/:id/targets/trashed</tt>
  # Affichage des cibles supprimées pour un actif
  def trashed
    list_targets
  end

  # <tt>GET /targets/:id</tt>
  # Affichage d'une cible et de ses détails
  def show
    common_breadcrumb(nil)
    add_breadcrumb @target.name
  end

  # <tt>GET /assets/:id/targets/new</tt>
  # Formulaire de création d'une nouvelle cible
  def new
    @target = Target.new
    new_data
  end

  # <tt>GET /targets/:id/edit</tt>
  # Modification d'une cible
  def edit
    edit_data
  end

  # <tt>POST /assets/:id/targets</tt>
  # Création d'une nouvelle cible
  def create
    params[:target][:asset_ids] = [params[:asset_id]]
    @target = Target.new(target_params)
    if @target.save
      redirect_to @target
    else
      new_data
      render 'new'
    end
  end

  # <tt>(PUT | PATCH) /targets/:id</tt>
  # MAJ d'une cible
  def update
    if @target.update(target_params)
      flash[:notice] = t('actions.notices.maj')
      redirect_to @target
    else
      edit_data
      render 'edit'
    end
  end

  # <tt>DELETE /targets/:id</tt>
  # Suppression (discard) d'une cible
  def destroy
    @target.discard
    notice = t(
      'targets.notices.deleted_html',
      target: html_escape_once(@target.name),
      cancel: helpers.link_to(
        t('targets.actions.restore'),
        restore_target_path(@target),
        method: :put,
        data: {
          confirm: t(
            'targets.actions.restore_confirm',
            infos: html_escape_once(@target.name)
          )
        }
      )
    )
    redirect_to targets_path, notice: notice
  end

  # <tt>PUT /targets/:id/restore</tt>
  # Restauration (undiscard) d'une cible
  def restore
    if @target.undiscard
      redirect_to @target, notice: t('targets.notices.restored', target: @target.name)
    else
      redirect_to trashed_targets_path, alert: t('targets.notices.cannot_restore')
    end
  end

  private

  def authorize!
    authorize(Target)
  end

  def authorize_target!
    authorize(@target)
  end

  def common_breadcrumb(asset)
    add_home_to_breadcrumb
    if asset.present?
      add_breadcrumb t('assets.section_title'), :assets_url
      add_breadcrumb asset.name, asset_path(asset.id)
      add_breadcrumb t('targets.section_title'), asset_targets_path(asset.id)
    else
      add_breadcrumb t('targets.section_title'), targets_path
    end
  end

  ### DATA HANDLERS ###
  def target_params
    params.require(:target).permit(policy(Target).permitted_attributes)
  end

  def list_targets
    common_breadcrumb(@asset)
    add_breadcrumb t('scopes.trashed') unless caller_locations(1..1).first.label == 'index'
    target_policy = TargetPolicy::Scope.new(current_user, Target)
    @targets = @asset.targets.includes(target_policy.list_includes)
    @q_base = @targets
    @q = @q_base.ransack params[:q]
    @q.sorts = ['name asc']
    @targets = @q.result.page(params[:page]).per(params[:per_page])
  end

  def new_data
    common_breadcrumb(@asset)
    add_breadcrumb t('targets.actions.create')
    @app_section = make_section_header(
      title: t('targets.actions.create'),
      actions: [TargetsHeaders.new.action(:back, :targets)]
    )
  end

  def edit_data
    common_breadcrumb(nil)
    add_breadcrumb @target.name, target_path(@target)
    add_breadcrumb "#{t('targets.actions.edit')} #{@target.name}"
    @app_section = make_section_header(
      title: t('targets.pages.edit', target: @target.name),
      actions: [TargetsHeaders.new.action(:back, target_path(@target))]
    )
  end

  def set_asset
    store_request_referer(assets_path)
    handle_unscoped { @asset = policy_scope(Asset).find(params[:asset_id]) }
  end

  def set_target
    store_request_referer(assets_path)
    handle_unscoped { @target = policy_scope(Target).find(params[:id]) }
  end

  def set_targets
    store_request_referer(dashboard_path)
    handle_unscoped do
      target_policy = TargetPolicy::Scope.new(current_user, Target)
      @targets = target_policy.resolve.includes(target_policy.all_includes)
    end
  end

  def set_trashed_target
    store_request_referer(targets_path)
    handle_unscoped { @target = policy_scope(Target).trashed.find(params[:id]) }
  end

  def set_js_objects
    @objects = Target::KINDS_ATTRIBUTES.to_json
  end

  ### HEADERS ###
  def set_collection_section_header
    @headers = AssetsHeaders.new
    headers = policy_headers(:asset, :member, @asset).filter
    @app_section = make_section_header(
      title: @asset.name,
      actions: @headers.actions(headers[:actions], @asset),
      scopes: @headers.tabs(headers[:tabs], @asset)
    )
  end

  def set_member_section_header
    @headers = TargetsHeaders.new
    headers = policy_headers(:target, :member, @target).filter
    @app_section = make_section_header(
      title: @target.name,
      actions: @headers.actions(headers[:actions], @target),
      other_actions: @headers.actions(headers[:other_actions], @target),
      scopes: @headers.tabs(headers[:tabs], @target)
    )
  end
end
