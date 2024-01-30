# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!, except: %i[public_key]
  before_action :authenticate_user_no_redir!, only: %i[public_key]
  before_action :authorize!, only: %i[index new create public_key]
  before_action :set_whodunnit
  # USER GENERIC
  before_action :set_users, only: %i[index]
  before_action :set_user, only: %i[show edit update public_key activate deactivate destroy
                                    send_unlock force_unlock
                                    send_reset_password force_reset_password
                                    resend_confirmation force_update_email force_confirm
                                    force_direct_otp force_deactivate_otp force_unlock_otp]
  before_action :set_trashed_user, only: %i[restore]
  before_action :authorize_user!, only: %i[show edit update activate deactivate destroy restore
                                           send_unlock force_unlock
                                           send_reset_password force_reset_password
                                           resend_confirmation force_update_email force_confirm
                                           force_direct_otp force_deactivate_otp force_unlock_otp]
  # HEADERS
  before_action :set_headers, only: %i[index show]
  before_action :set_collection_section_header, only: %i[index]
  before_action :set_member_section_header, only: %i[show]
  include MfaController

  def initialize
    @models = self.class.name.delete_suffix('Controller')
    @model_u = @models.singularize.underscore
    @models_u = @models.underscore
    @user_clazz = @models.singularize.to_sym
    super
  end

  # GET /@models_u
  def index
    common_breadcrumb
    @q_base = @users
    @q = @q_base.ransack params[:q]
    @q.sorts = ['full_name asc', 'created_at desc'] if @q.sorts.blank?
    @users = @q.result.page(params[:page]).per(params[:per_page])
  end

  # GET /@models_u/new
  def show
    common_breadcrumb
    add_breadcrumb @user.full_name
  end

  # POST /@models_u
  def new
    @user = User.new
    new_data
  end

  # GET /@models_u/:id
  def edit
    edit_data
  end

  # GET /@models_u/:id/edit
  def create
    allowed_params = send(:"#{@model_u}_params")
    @user = User.new(allowed_params.except(:role_ids))
    if params[@model_u.to_sym][:send_confirmation_notification].to_i.zero?
      @user.skip_confirmation_notification!
    end
    if @user.save
      @user.current_group = Group.send(@model_u)
      if allowed_params.key?(:role_ids)
        @user.roles << Role.find(allowed_params.slice(:role_ids)[:role_ids].compact_blank)
      end
      redirect_to send(:"#{@model_u}_path", @user)
    else
      new_data
      render "#{@models_u}/new"
    end
  end

  # PATCH|PUT /@models_u/:id
  def update
    handle_params
    if @user.update(send(:"#{@model_u}_params"))
      redirect_to send(:"#{@model_u}_path", @user)
    else
      edit_data
      render 'edit'
    end
  end

  ## RECOVERABLE ##

  # PUT /@models_u/:id/force_reset_password
  # support_admin creates new password
  def force_reset_password
    valid = @user.reset_password(params[:user][:password], params[:user][:password_confirmation])
    if valid
      redirect_to back_in_history, notice: t('users.notices.password_success')
    else
      set_headers
      flash.now[:alert] = t('users.notices.password_fail')
      render 'show'
    end
  end

  # POST /@models_u/:id/send_reset_password
  # Envoi des instructions de changement de mot de passe
  def send_reset_password
    @user.send_reset_password_instructions
    redirect_to back_in_history, notice: t('users.notices.reset_password_sent')
  end

  ## CONFIRMABLE ##

  # PUT /@models_u/:id/resend_confirmation
  # Renvoi des instructions de confirmation d'email par email
  def resend_confirmation
    @user.resend_confirmation_instructions
    redirect_to back_in_history, notice: t('users.notices.confirmation_sent')
  end

  # PUT /@models_u/:id/force_update_email
  # supper_admin updates email without confirmation
  def force_update_email
    @user.email = params[:user][:email]
    @user.skip_reconfirmation!
    if @user.save
      redirect_to back_in_history, notice: t('users.notices.email_update_success')
    else
      set_headers
      flash.now[:alert] = t('users.notices.email_update_fail')
      render 'show'
    end
  end

  # PUT /@models_u/:id/force_confirm
  # Force email confirmation
  def force_confirm
    @user.confirm!
    redirect_to back_in_history, notice: t('users.notices.forced_email_confirmation')
  end

  ## OTPABLE ##

  # PUT /@models_u/:id/force_direct_otp
  def force_direct_otp
    @user.clear_otp_authenticator
    redirect_to back_in_history, notice: t('users.notices.forced_direct_otp')
  end

  # PUT /@models_u/:id/force_deactivate_otp
  def force_deactivate_otp
    @user.deactivate_otp
    redirect_to back_in_history, notice: t('users.notices.forced_otp_deactivation')
  end

  def force_unlock_otp
    @user.unlock_otp
    redirect_to back_in_history, notice: t('users.notices.forced_unlock_otp')
  end

  ## UNLOCKABLE ##

  # POST /@models_u/:id/send_unlock
  # Envoi des instructions de déblocage du compte
  def send_unlock
    @user.send_unlock_instructions
    redirect_to back_in_history, notice: t('users.notices.unlock_sent')
  end

  # PUT /@models_u/:id/force_unlock
  def force_unlock
    @user.unlock_access!
    redirect_to back_in_history, notice: t('users.notices.forced_unlock')
  end

  ## ACTIVABLE ##

  # PUT /@models_u/:id/activate
  # Activation du compte
  # Statut = Actif
  def activate
    @user.actif!
    redirect_to back_in_history, notice: t('users.notices.activated')
  end

  # PUT /@models_u/:id/deactivate
  # Désactivation du compte
  def deactivate
    @user.inactif!
    redirect_to back_in_history, notice: t('users.notices.deactivated')
  end

  ## RESTORABLE ##

  # DELETE /@models_u/:id
  # Discard du compte
  def destroy
    @text_flash = t('users.notices.deletion_failure')

    if send(:"#{@model_u}_in_perimeter?") && @user.discard
      flash[:notice] = t('users.notices.deletion_success')
    else
      flash[:alert] = @text_flash
    end

    redirect_to back_in_history
  end

  # PUT /@models_u/:id/restore
  # Undiscard du compte
  def restore
    @user.undiscard
    redirect_to back_in_history, notice: t('users.notices.restored')
  end

  ## GPGABLE ##

  # AJAX
  # GET /users/:id/public_key
  def public_key
    if @user.public_key.present?
      render json: {
        title: t('labels.public_key'), html: render_to_string(partial: 'users/public_key')
      }
    else
      render json: :error
    end
  end

  private

  def authorize!
    authorize(@user_clazz)
  end

  def set_headers
    @headers = instance_eval("#{@models}Headers", __FILE__, __LINE__).new
  end

  def common_breadcrumb
    add_home_to_breadcrumb
    add_breadcrumb t("#{@models_u}.section_title"), send(:"#{@models_u}_url")
  end

  def new_data
    common_breadcrumb
    title = t("#{@models_u}.actions.create")
    add_breadcrumb title
    @app_section = make_section_header(
      title: title,
      actions: [HeadersHandler.new.action(:back, back_in_history)]
    )
  end

  def edit_data
    common_breadcrumb
    add_breadcrumb @user.full_name, send(:"#{@model_u}_path", @user)
    add_breadcrumb t("#{@models_u}.actions.edit")
    @app_section = make_section_header(
      title: t("#{@models_u}.pages.edit", user: @user.full_name),
      actions: [HeadersHandler.new.action(:back, back_in_history)]
    )
  end

  def set_user
    handle_unscoped do
      @user = policy_scope(@user_clazz).find(params[:id])
    end
  end

  def set_users
    policy = instance_eval("#{@user_clazz}Policy::Scope", __FILE__, __LINE__)
             .new(current_user, @user_clazz)
    @users = policy.resolve.includes(policy.list_includes)
  end

  def set_trashed_user
    handle_unscoped do
      @user = policy_scope(@user_clazz).trashed.find(params[:id])
    end
  end

  def authorize_user!
    authorize(@user, policy_class: "#{@user_clazz}Policy".constantize)
  end

  def set_collection_section_header
    @app_section = make_section_header(
      title: t("#{@models_u}.section_title"),
      actions: @headers.actions(policy_headers(@model_u.to_sym, :collection).actions, nil)
    )
  end

  def set_member_section_header
    headers_policy = policy_headers(@model_u.to_sym, :member, @user)
    @app_section = make_section_header(
      title: @user.full_name,
      actions: @headers.actions(headers_policy.actions, @user),
      other_actions: @headers.actions(headers_policy.other_actions, @user)
    )
  end
end
