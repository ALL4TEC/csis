# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include PunditController

  respond_to :html, :json

  before_action lambda {
    flash.now[:notice] = flash[:notice] if flash[:notice]
  }
  before_action :store_user_location!, if: :storable_location?
  before_action :set_locale
  before_action :store_request_referer
  attr_reader :app_section

  NAV_INFOS = {
    staff: [
      [{ title: 'assets', path: :my_assets, icon: Icons::MAT[:assets] }],
      [{ title: 'projects', path: :projects, icon: Icons::MAT[:dashboard] }],
      [{ title: 'actions', path: :actions, icon: Icons::MAT[:actions] }],
      [{ title: 'vulnerabilities', path: :vulnerabilities, icon: Icons::MAT[:vulnerabilities] }],
      [{ title: 'administration', icon: Icons::MAT[:administration] },
       { title: 'groups', path: :groups, icon: Icons::MAT[:groups], role: :super_admin },
       { title: 'remediation', header: true },
       { title: 'clients', path: :clients, icon: Icons::MAT[:clients] },
       { title: 'contacts', path: :contacts, icon: Icons::MAT[:contacts] },
       { title: 'cyber', header: true },
       { title: 'teams', path: :teams, icon: Icons::MAT[:teams] },
       { title: 'staffs', path: :staffs, icon: Icons::MAT[:staffs] }],
      [{ title: 'data', icon: Icons::MAT[:statistics] },
       { title: 'statistics', path: :statistics, icon: Icons::MAT[:pie_chart] },
       { title: 'exports', path: 'statistics/export', icon: Icons::MAT[:export] }],
      [{ title: 'configuration', icon: Icons::MAT[:configuration] },
       { title: 'authentication', header: true },
       { title: 'idp_configs', path: :idp_configs, icon: Icons::MAT[:idp_configs],
         role: :super_admin },
       { title: 'communication', header: true },
       { title: 'chat_configs', path: :chat_configs, icon: Icons::MAT[:chat] },
       { title: 'ticketing', header: true },
       { title: 'jira_configs', path: :jira_configs, logo: Icons::LOGOS[:jira],
         disabled: !Rails.application.config.jira_enabled },
       { title: 'servicenow_configs', path: :servicenow_configs, logo: Icons::LOGOS[:servicenow],
         disabled: !Rails.application.config.servicenow_enabled },
       { title: 'matrix42_configs', path: :matrix42_configs, logo: Icons::LOGOS[:matrix42],
         disabled: !Rails.application.config.matrix42_enabled },
       { title: 'scanners', header: true, role: :super_admin },
       { title: 'qualys_configs', path: :qualys_configs, logo: Icons::LOGOS[:qualys],
         disabled: !Rails.application.config.qualys_enabled },
       { title: 'insight_app_sec_configs', path: :insight_app_sec_configs,
         logo: Icons::LOGOS[:rapid7], disabled: !Rails.application.config.rapid7_ias_enabled },
       { title: 'cyberwatch_configs', path: :cyberwatch_configs, logo: Icons::LOGOS[:cyberwatch],
         disabled: !Rails.application.config.cyberwatch_enabled },
       { title: 'provisioning', header: true, role: :super_admin },
       { title: 'sellsy_configs', path: :sellsy_configs, logo: Icons::LOGOS[:sellsy],
         disabled: !Rails.application.config.sellsy_enabled }]
    ].freeze,
    contact: [
      [{ title: 'assets', path: :my_assets, icon: Icons::MAT[:assets] }],
      [{ title: 'projects', path: :projects, icon: Icons::MAT[:dashboard] }],
      [{ title: 'actions', path: :actions, icon: Icons::MAT[:actions] }],
      [{ title: 'clients', path: :clients, icon: Icons::MAT[:clients], role: :contact_admin }],
      [{ title: 'contacts', path: :contacts, icon: Icons::MAT[:contacts] }],
      [{ title: 'data', icon: Icons::MAT[:statistics] },
       { title: 'statistics', path: :statistics, icon: Icons::MAT[:pie_chart] },
       { title: 'exports', path: 'statistics/export', icon: Icons::MAT[:export] }]
    ].freeze
  }.freeze

  # Call at every page changement to set the language
  # With before_action
  def set_locale
    if session[:locale].present?
      I18n.locale = session[:locale]

    elsif user_signed_in? && current_user.language.present?
      session[:locale] = current_user.language.iso
      I18n.locale = session[:locale]

    else
      I18n.locale = I18n.default_locale
    end
  end

  # Call with flag click only
  # Has a redirect
  def change_locale
    if params[:locale].present?
      session[:locale] = params[:locale]
      I18n.locale = params[:locale]
    elsif session[:locale].present?
      I18n.locale = session[:locale]
    else
      I18n.locale = I18n.default_locale
    end
    redirect_back(fallback_location: root_path)
  end

  protected

  def after_sign_out_path_for(_resource)
    login_path
  end

  def make_section_header(opts)
    Inuit::SectionHeader.new(request, opts)
  end

  def html_escape_once(input)
    ERB::Util.html_escape_once(input)
  end

  # Définis la personne désignée comme responsable dans les journaux d'audits générés par ce
  # contrôleur.
  def set_whodunnit
    PaperTrail.request.whodunnit = session[:user_id] || current_user.id
  end

  def add_home_to_breadcrumb
    add_breadcrumb t('dashboard.section_title'), :dashboard_url
  end

  def store_request_referer(fallback = root_path)
    session[:return_to] = request.referer || fallback
  end

  # Rescue ActiveRecord::NotFound to redirect not authorized users !
  def handle_unscoped
    yield
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = t('activerecord.errors.not_found').to_s
    redirect_back_in_history
  end

  # **@params clazz: ** Class to instantiate
  # **@params kind: **
  # **@params record: **
  # **@params policy: **
  # @returns instantiated policy headers
  def policy_headers(clazz, kind, record = nil, policy = nil)
    instance_eval("#{clazz.to_s.classify}Policy::Headers", __FILE__, __LINE__)
      .new(current_user, kind, record, policy)
  end

  private

  # **@params data:** Base data to search from
  # **@params sort_ary:** Array used to sort filtered data
  # @returns paginated results
  def filtered_list(data, sort_ary)
    @q_base = data
    @q = @q_base.ransack params[:q]
    @q.sorts = sort_ary if @q.sorts.blank?
    @q.result.page(params[:page]).per(params[:per_page])
  end

  # If session[:return_to].present? back_in_history else redirect_back(fallback)
  def redirect_back_in_history(fallback = root_path)
    if session[:return_to].present?
      redirect_to(back_in_history)
    else
      redirect_back(fallback_location: fallback)
    end
  end

  def back_in_history
    session.delete(:return_to)
  end

  # Its important that the location is NOT stored if:
  # - The request method is not GET (non idempotent)
  # - The request is handled by a Devise controller such as Devise::SessionsController as that
  #    could cause an infinite redirect loop.
  # - The request is an Ajax request as this can lead to very unexpected behaviour.
  # - The request does not contain logout (SAML SLO)
  def storable_location?
    request.get? && is_navigational_format? && !devise_controller? && !request.xhr? &&
      request.url.exclude?('logout')
  end

  def store_user_location!
    store_location_for(:user, request.fullpath)
  end

  def after_sign_in_path_for(resource_or_scope)
    stored_location_for(resource_or_scope) || super
  end

  def user_not_authorized
    flash[:alert] = t('actions.notices.no_rights')
    redirect_back(fallback_location: root_path)
  end

  def clear_notifs
    flash.now[:notice] = session.delete(:notice) if session[:notice].present?
  end

  # Method to trace suspicious requests and actions
  def log_suspicious(user, method, data, opts = nil)
    logger.warn("#{user}, #{method}, #{data}, #{opts}")
  end
end
