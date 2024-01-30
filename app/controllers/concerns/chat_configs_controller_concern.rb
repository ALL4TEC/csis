# frozen_string_literal: true

class ChatConfigsControllerConcern < ApplicationController
  before_action :authenticate_user!
  before_action :authorize!
  before_action :set_whodunnit
  before_action :set_chat_config, only: %i[edit update destroy]
  before_action :set_chat_configs, only: %i[index]
  before_action :set_collection_section_header, only: %i[index]

  NAME_ASC = ['name asc'].freeze

  def initialize
    @models = self.class.name.delete_suffix('Controller')
    @models_u = @models.underscore
    @model = @models.singularize
    @model_u = @model.underscore
    @clazz = instance_eval(@model)
    @headers = instance_eval("#{@models}Headers", __FILE__, __LINE__).new
    super
  end

  def index
    common_breadcrumb
  end

  def new
    if params[:chat_application_id].present?
      @chat_application = ChatApplication.find(params[:chat_application_id])
      @chat_config = @clazz.new(chat_application: @chat_application)
    else
      @chat_config = @clazz.new
    end
    new_data
  end

  def edit
    edit_data
  end

  def create
    @clazz.create!(handle_params)
    redirect_to @models_u.to_sym
  end

  def update
    if @chat_config.update(handle_params)
      redirect_to @models_u.to_sym
    else
      edit_data
      render 'edit'
    end
  end

  def destroy
    if @chat_config.destroy
      flash[:notice] = t("#{@models_u}.notices.deletion_success")
    else
      flash[:alert] = t("#{@models_u}.notices.deletion_failure")
    end
    redirect_to @models_u.to_sym
  end

  private

  def common_breadcrumb
    add_home_to_breadcrumb
    add_breadcrumb t("#{@models_u}.section_title"), :"#{@models_u}_url"
  end

  def new_data
    common_breadcrumb
    add_breadcrumb t("#{@models_u}.actions.create")
    @app_section = make_section_header(
      title: t("#{@models_u}.actions.create"),
      actions: [@headers.action(:back, @models_u.to_sym)]
    )
  end

  def edit_data
    common_breadcrumb
    add_breadcrumb @chat_config.name
    add_breadcrumb t("#{@models_u}.actions.edit")
    @app_section = make_section_header(
      title: t("#{@models_u}.pages.edit", chat_config: @chat_config.name),
      actions: [@headers.action(:back, @models_u.to_sym)]
    )
  end

  def chat_config_params
    params.require(@model_u).permit(policy(@clazz).permitted_attributes)
  end

  def handle_params
    mapper = instance_eval("Chat::#{@model}Mapper", __FILE__, __LINE__)
    mapper.chat_config_h(chat_config_params, current_user)
  end

  # We can authorize all methods here as authorizations do not need further record informations
  def authorize!
    authorize(@clazz)
  end

  def set_chat_config
    handle_unscoped do
      @chat_config = policy_scope(@clazz).find(params[:id])
    end
    # ?
    # cookies[@model_u] = @chat_config.name
  end

  def set_chat_configs
    @chat_configs = filtered_list(policy_scope(@clazz), NAME_ASC)
  end

  # HEADERS
  def set_collection_section_header
    @app_section = make_section_header(
      title: t("#{@models_u}.section_title"),
      actions: [@headers.action(:create, nil)],
      scopes: @headers.tabs(policy_headers(@model_u, :list).tabs, @chat_config)
    )
  end
end
