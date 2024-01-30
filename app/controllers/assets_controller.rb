# frozen_string_literal: true

class AssetsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize!, only: %i[index new create]
  before_action :set_whodunnit
  before_action :set_asset, only: %i[show edit update destroy]
  before_action :set_trashed_asset, only: %i[restore]
  before_action :authorize_asset!, only: %i[show edit update destroy restore]
  before_action :set_assets, only: %i[index trashed]
  before_action :set_collection_section_header, only: %i[index trashed]
  before_action :set_member_section_header, only: %i[show]

  ### ENDPOINTS ###

  # <tt>GET /assets</tt>
  # Affichage des actifs pour un membre du staff
  def index
    list_assets
  end

  # <tt>GET /assets/trashed</tt>
  # Affichage des actifs supprimés pour un membre du staff
  def trashed
    list_assets
  end

  # <tt>GET /assets/:id</tt>
  # Formulaire de création d'un nouvel actif
  def show
    common_breadcrumb
    add_breadcrumb @asset.name
  end

  # <tt>GET /assets/new</tt>
  # Création d'un nouvel actif
  def new
    @asset = Asset.new
    new_data
  end

  # <tt>GET /assets/:id/edit</tt>
  # Affichage d'un actif et de ses détails
  def edit
    edit_data
  end

  # <tt>POST /assets</tt>
  # Modification d'un actif
  def create
    @asset = Asset.new(asset_params)
    if @asset.save
      redirect_to @asset
    else
      new_data
      render 'new'
    end
  end

  # <tt>(PUT | PATCH) /assets/:id</tt>
  # MAJ d'un actif
  def update
    if @asset.update(asset_params)
      flash[:notice] = t('actions.notices.maj')
      redirect_to @asset
    else
      edit_data
      render 'edit'
    end
  end

  # <tt>DELETE /assets/:id</tt>
  # Suppression (discard) d'un actif
  def destroy
    @asset.discard
    notice = t(
      'assets.notices.deleted_html',
      asset: html_escape_once(@asset.name),
      cancel: helpers.link_to(
        t('assets.actions.restore'),
        restore_asset_path(@asset),
        method: :put,
        data: {
          confirm: t(
            'assets.actions.restore_confirm',
            infos: html_escape_once(@asset.name)
          )
        }
      )
    )
    redirect_to assets_path, notice: notice
  end

  # <tt>PUT /assets/:id/restore</tt>
  # Restauration (undiscard) d'un actif
  def restore
    if @asset.undiscard
      redirect_to @asset, notice: t('assets.notices.restored', asset: @asset.name)
    else
      redirect_to trashed_assets_path, alert: t('assets.notices.cannot_restore')
    end
  end

  private

  def authorize!
    authorize(Asset)
  end

  def authorize_asset!
    authorize(@asset)
  end

  def common_breadcrumb
    add_home_to_breadcrumb
    add_breadcrumb t('assets.section_title'), :assets_url
  end

  ### DATA HANDLERS ###
  def asset_params
    params.require(:asset).permit(policy(Asset).permitted_attributes)
  end

  def list_assets
    common_breadcrumb
    add_breadcrumb t('scopes.trashed') unless caller_locations(1..1).first.label == 'index'
    @assets = filtered_list(@assets, ['name asc'])
  end

  def new_data
    common_breadcrumb
    add_breadcrumb t('assets.actions.create')
    @app_section = make_section_header(
      title: t('assets.actions.create'),
      actions: [AssetsHeaders.new.action(:back, :assets)]
    )
  end

  def edit_data
    asset = Asset.find(@asset.id)
    common_breadcrumb
    add_breadcrumb asset.name, asset_path(@asset)
    add_breadcrumb "#{t('assets.actions.edit')} #{asset.name}"
    @app_section = make_section_header(
      title: t('assets.pages.edit', asset: asset.name),
      actions: [AssetsHeaders.new.action(:back, asset_path(@asset))]
    )
  end

  def set_asset
    store_request_referer(assets_path)
    handle_unscoped { @asset = policy_scope(Asset).find(params[:id]) }
  end

  def set_assets
    store_request_referer(dashboard_path)
    handle_unscoped do
      asset_policy = AssetPolicy::Scope.new(current_user, Asset)
      @assets = asset_policy.resolve.includes(asset_policy.list_includes)
    end
  end

  def set_trashed_asset
    store_request_referer(assets_path)
    handle_unscoped { @asset = policy_scope(Asset).trashed.find(params[:id]) }
  end

  ### HEADERS ###
  def set_collection_section_header
    @headers = AssetsHeaders.new
    headers = policy_headers(:asset, :collection).filter
    @app_section = make_section_header(
      title: t('assets.section_title'),
      actions: @headers.actions(headers[:actions], nil),
      scopes: @headers.tabs(headers[:tabs], @assets)
    )
    scope = params[:action] == 'trashed' ? 'trashed' : 'kept'
    @assets = @assets.send(scope)
  end

  def set_member_section_header
    @headers = AssetsHeaders.new
    headers = policy_headers(:asset, :member, @asset).filter
    @app_section = make_section_header(
      title: @asset.name,
      actions: @headers.actions(headers[:actions], @asset),
      other_actions: @headers.actions(headers[:other_actions], @asset),
      scopes: @headers.tabs(headers[:tabs], @asset)
    )
  end
end
