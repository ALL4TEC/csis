# frozen_string_literal: true

class SlackApplicationsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize!
  before_action :set_whodunnit
  before_action :set_slack_application, only: %i[edit update destroy]

  def self.controller_path
    'chat_configs/slack_config/slack_applications'
  end

  def new
    @slack_application = SlackApplication.new
    new_data
  end

  def edit
    edit_data
  end

  def create
    slack_application = SlackApplication.new(slack_application_params)
    if slack_application.save
      redirect_to slack_configs_path
    else
      new_data
      render 'new'
    end
  end

  def update
    if @slack_application.update(slack_application_params)
      redirect_to slack_configs_path
    else
      edit_data
      render 'edit'
    end
  end

  def destroy
    if @slack_application.destroy
      flash[:notice] = t('slack_applications.notices.deletion_success')
    else
      flash[:alert] = t('slack_applications.notices.deletion_failure')
    end
    redirect_to slack_configs_path
  end

  private

  def common_breadcrumb
    add_home_to_breadcrumb
    add_breadcrumb t('slack_applications.section_title'), :slack_configs_url
  end

  def new_data
    common_breadcrumb
    add_breadcrumb t('slack_applications.actions.create')
    @app_section = make_section_header(
      title: t('slack_applications.actions.create'),
      actions: [SlackApplicationsHeaders.new.action(:back, :slack_applications)]
    )
  end

  def edit_data
    common_breadcrumb
    add_breadcrumb @slack_application.name
    @app_section = make_section_header(
      title: t('slack_applications.pages.edit', slack_application: @slack_application.name),
      actions: [SlackApplicationsHeaders.new.action(:back, :slack_applications)]
    )
  end

  def slack_application_params
    params.require(:slack_application).permit(policy(SlackApplication).permitted_attributes)
  end

  # We can authorize all methods here as authorizations do not need further record informations
  def authorize!
    authorize(SlackApplication)
  end

  def set_slack_application
    id = params[:id]
    handle_unscoped do
      @slack_application = policy_scope(SlackApplication).find(id)
    end
    # cookies[:slack_application] = @slack_application.client_id
  end

  # HEADERS -> slack_configs
  def set_collection_section_header
    @app_section = make_section_header(
      title: t('slack_applications.section_title'),
      filter_btn: true,
      actions: [
        SlackApplicationsHeaders.new.action(:create, nil)
      ]
    )
  end
end
