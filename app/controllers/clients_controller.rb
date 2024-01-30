# frozen_string_literal: true

class ClientsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize!, only: %i[index new create show]
  before_action :set_whodunnit
  before_action :set_client, only: %i[show edit update destroy restore]
  before_action :authorize_client!, only: %i[edit update destroy restore]
  before_action :set_clients, only: %i[index]
  before_action :set_collection_section_header, only: %i[index]
  before_action :set_member_section_header, only: %i[show]

  include MfaController

  def index
    common_breadcrumb
    @clients = filtered_list(@clients, ['name asc'])
  end

  def show
    common_breadcrumb
    add_breadcrumb @client.name
    @user_clazz = :Contact
  end

  def new
    @client = Client.new
    new_data
  end

  def edit
    edit_data
  end

  def create
    @client = Client.new(client_params)
    if contacts_valid? && @client.save
      redirect_to @client
    else
      new_data
      render 'new'
    end
  end

  def update
    if contacts_valid? && @client.update(client_params)
      redirect_to @client
    else
      edit_data
      render 'edit'
    end
  end

  def restore
    @client.undiscard
    redirect_to clients_path, notice: t('clients.notices.restored')
  end

  def destroy
    if @client.discard
      flash[:notice] = t('clients.notices.deletion_success')
    else
      flash[:alert] = t('clients.notices.deletion_failure')
    end
    redirect_to clients_path
  end

  private

  def authorize!
    authorize(Client)
  end

  def authorize_client!
    authorize(@client)
  end

  def common_breadcrumb
    add_home_to_breadcrumb
    add_breadcrumb t('clients.section_title'), :clients_url
  end

  def new_data
    common_breadcrumb
    add_breadcrumb t('clients.actions.create')
    @app_section = make_section_header(
      title: t('clients.actions.create'),
      actions: [ClientsHeaders.new.action(:back, back_in_history)]
    )
  end

  def edit_data
    common_breadcrumb
    add_breadcrumb @client.name, client_path(@client)
    add_breadcrumb t('clients.actions.edit')
    @app_section = make_section_header(
      title: t('clients.pages.edit', client: @client.name),
      actions: [ClientsHeaders.new.action(:back, back_in_history)]
    )
  end

  def contacts_valid?
    valid = policy(@client).contacts_valid?(params)
    flash[:alert] = t('clients.notices.member_empty') unless valid
    valid
  end

  def client_params
    params.require(:client).permit(policy(Client).permitted_attributes)
  end

  def set_client
    store_request_referer(clients_path)
    handle_unscoped do
      client_policy = ClientPolicy::Scope.new(current_user, Client)
      @client = client_policy.resolve.includes(client_policy.send(:"#{params[:action]}_includes"))
                             .find(params[:id])
    end
  end

  def set_clients
    @clients = policy_scope(Client)
  end

  def set_collection_section_header
    @headers = ClientsHeaders.new
    @app_section = make_section_header(
      title: t('clients.section_title'),
      subtitle: t('clients.section_subtitle', count: policy_scope(Client).count),
      actions: @headers.actions(policy_headers(:client, :collection).actions, nil)
    )
  end

  def set_member_section_header
    @headers = ContactsHeaders.new
    clients_h = ClientsHeaders.new
    url = @client.web_url
    headers_policy = policy_headers(:client, :member, @client)
    @app_section = make_section_header(
      title: @client.name,
      subtitle: url.nil? ? nil : Inuit::ExternalLink.new(@client.web_url, @client.web_url),
      actions: clients_h.actions(headers_policy.actions, @client),
      other_actions: clients_h.actions(headers_policy.other_actions, @client)
    )
  end
end
