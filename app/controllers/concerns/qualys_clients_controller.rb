# frozen_string_literal: true

class QualysClientsController < ApplicationController
  include BouncerController

  before_action :set_qualys_config, except: %i[list show destroy edit update]
  before_action :set_qualys_client, only: %i[show edit update destroy]
  before_action :extract_qualys_config, only: %i[edit update destroy]
  before_action :set_list_section_header, only: %i[list]
  before_action :set_collection_section_header, only: %i[index]
  before_action :set_member_section_header, only: %i[show]

  def initialize
    models = self.class.name.delete_suffix('Controller')
    @model_u = models.singularize.underscore
    @models_u = models.underscore
    @clazz = instance_eval(models.singularize)
    @headers = instance_eval("#{models}Headers", __FILE__, __LINE__) # QualysVm/WaClientsHeaders
    super
  end

  def self.controller_path
    :qualys_clients
  end

  def list
    common_breadcrumb
    q_client_policy = instance_eval("#{@clazz}Policy::Scope", __FILE__, __LINE__) # Rubocop
                      .new(current_user, @clazz)
    @q_base = q_client_policy.resolve.includes(q_client_policy.list_includes) # For filters
    @q = @q_base.ransack params[:q]
    @q.sorts = ['name asc', 'created_at desc'] if @q.sorts.blank?
    @qualys_clients = @q.result.page(params[:page]).per(params[:per_page])
    render 'index'
  end

  def index
    list
  end

  def show
    common_breadcrumb
    add_breadcrumb @qualys_client.qualys_name
  end

  def new
    @qualys_client = @clazz.new
    new_data
  end

  def edit
    edit_data
  end

  def create
    @qualys_client = @clazz.new(qualys_client_params)
    @qualys_client.qualys_config_id = @qualys_config.id
    if @qualys_client.save
      redirect_to @qualys_client
    else
      new_data
      render 'new'
    end
  end

  def update
    if @qualys_client.update(qualys_client_params)
      redirect_to @qualys_client
    else
      edit_data
      render 'edit'
    end
  end

  def destroy
    if @qualys_client.destroy
      flash[:notice] = t("#{@models_u}.notices.deletion_success")
    else
      flash[:alert] = t("#{@models_u}.notices.deletion_failure")
    end
    redirect_to send(:"#{@models_u}_path")
  end

  private

  def common_breadcrumb
    add_home_to_breadcrumb
    add_breadcrumb t('qualys_configs.section_title'), :qualys_configs_url
    if @qualys_config.present?
      add_breadcrumb @qualys_config.name, qualys_config_path(@qualys_config)
      url = send(:"qualys_config_#{@models_u}_path", @qualys_config)
      add_breadcrumb t("#{@models_u}.section_title"), url
    else
      add_breadcrumb t("#{@models_u}.section_title"), send(:"#{@models_u}_url")
    end
  end

  def new_data
    common_breadcrumb
    add_breadcrumb t("#{@models_u}.actions.create")
    @app_section = make_section_header(
      title: t("#{@models_u}.actions.create"),
      actions: [@headers.new.action(:back, back_in_history)]
    )
  end

  def edit_data
    common_breadcrumb
    add_breadcrumb @qualys_client.qualys_name, send(:"#{@model_u}_path", @qualys_client)
    add_breadcrumb t("#{@models_u}.actions.edit")
    @app_section = make_section_header(
      title: t("#{@models_u}.pages.edit", qualys_client: @qualys_client.qualys_name),
      actions: [@headers.new.action(:back, back_in_history)]
    )
  end

  def qualys_client_params
    params.require(@model_u.to_sym).permit(policy(@clazz).permitted_attributes)
  end

  def authorize!
    authorize(@clazz)
  end

  def extract_qualys_config
    @qualys_config = @qualys_client.qualys_config
  end

  def set_qualys_config
    handle_unscoped { @qualys_config = policy_scope(QualysConfig).find(params[:qualys_config_id]) }
  end

  def set_qualys_client
    handle_unscoped { @qualys_client = policy_scope(@clazz).find(params[:id]) }
  end

  def set_collection_section_header
    @app_section = make_section_header(title: t("#{@models_u}.section_title"),
      actions: [@headers.new.action(:create, @qualys_config)])
  end

  def set_list_section_header
    @app_section = make_section_header(title: t("#{@models_u}.section_title"))
  end

  def set_member_section_header
    headers = @headers.new
    @app_section = make_section_header(
      title: @qualys_client.qualys_name,
      actions: [headers.action(:edit, @qualys_client)],
      other_actions: [headers.action(:destroy, @qualys_client)]
    )
  end
end
