# frozen_string_literal: true

require 'rqrcode'

class Users::ProfileController < ApplicationController
  before_action :authenticate_user_no_redir!, only: %i[test_totp_configuration]
  before_action :authenticate_user!, except: %i[test_totp_configuration]
  before_action :set_whodunnit
  before_action :set_profile_user # No need for authorize as @user is current_user
  before_action :set_group, only: %i[switch_current_group]
  before_action :authorize_user!, only: %i[activate_otp deactivate_otp setup_otp_authenticator
                                           resetup_otp_authenticator configure_totp
                                           clear_otp_authenticator test_totp_configuration]
  before_action :set_member_section_header

  # GET /profile
  def show; end

  # GET /edit/notifications
  def edit_notifications; end

  # PUT /edit/notifications
  def update_notifications
    permitted_params = params.require(:user)
                             .permit(policy([User, :profile]).permitted_notifications_attributes)
    can_save = Users::ProfileParamsHandler.call(permitted_params)
    current_user.update(permitted_params) if can_save
    render 'edit_notifications'
  end

  # GET /edit/password
  def edit_password; end

  # PUT /edit/password
  def update_password
    permitted_params = params.require(:user)
                             .permit(policy([User, :profile]).permitted_password_attributes)
    @user.update_with_password(permitted_params)
    render 'edit_password'
  end

  # GET /edit/public_key
  def edit_public_key; end

  # PUT /edit/public_key
  def update_public_key
    permitted_params = params.require(:user)
                             .permit(policy([User, :profile])
                             .permitted_public_key_attributes)
    @user.update_without_password(permitted_params)
    render 'edit_public_key'
  end

  # GET /edit/display
  def edit_display; end

  # PUT /edit/display
  def update_display
    permitted_params = params.require(:user)
                             .permit(policy([User, :profile])
                             .permitted_display_attributes)
    @user.update_without_password(permitted_params)
    redirect_to edit_profile_display_path
  end

  # GET /edit/otp
  def edit_otp; end

  # GET /otp/authenticator/:token
  def configure_totp
    raise Pundit::NotAuthorizedError unless @user.totp_configuration_token == params[:token]

    @user.validate_totp_configuration
    issuer = "CSIS [#{ENV.fetch('ROOT_URL')[%r{.*://(.*)}, 1]}]"
    @uri = @user.provisioning_uri(@user.email, { issuer: issuer })
    qrcode = RQRCode::QRCode.new(@uri)

    # NOTE: showing with default options specified explicitly
    @qrcode_data = qrcode.as_png(
      bit_depth: 1,
      border_modules: 4,
      color_mode: ChunkyPNG::COLOR_GRAYSCALE,
      color: 'black',
      file: nil,
      fill: 'white',
      module_px_size: 6,
      resize_exactly_to: false,
      resize_gte_to: false,
      size: 360
    ).to_s
  end

  # PUT /switch_current_group/:id
  def switch_current_group
    # Maybe allow super_admin to switch user type after provisioning
    @user.switch_type(@group)
    redirect_to(
      dashboard_path,
      notice: t("users.notices.switched_to_#{@group.name.singularize.downcase}")
    )
  end

  # POST /otp/deactivate
  def deactivate_otp
    @user.deactivate_otp
    redirect_to edit_profile_otp_path
  end

  # POST /otp/activate
  def activate_otp
    @user.activate_otp
    redirect_to edit_profile_otp_path
  end

  # POST /otp/authenticator/setup
  def setup_otp_authenticator
    @user.setup_otp_authenticator
    redirect_to configure_otp_authenticator_path(token: @user.totp_configuration_token)
  end

  # POST /otp/authenticator/setup/new
  # Only needed compared to setup for authorize call to check
  # if user has already setup once
  def resetup_otp_authenticator
    setup_otp_authenticator
  end

  # POST /otp/authenticator/clear
  def clear_otp_authenticator
    @user.clear_otp_authenticator
    redirect_to edit_profile_otp_path
  end

  # POST /otp/authenticator/test
  # AJAX
  def test_totp_configuration
    @authenticated = @user.authenticate_totp(params[:code])
  end

  private

  def authorize_user!
    authorize(@user, policy_class: User::ProfilePolicy)
  end

  def set_profile_user
    @user = current_user
  end

  def set_group
    # Set group
    handle_unscoped do
      # No policy here as we want to switch view even if not a super_admin
      @group = @user.groups.find(params[:id])
    end
  end

  def set_member_section_header
    headers_policy = User::ProfilePolicy::Headers.new(current_user, :member, nil, nil)
    @app_section = make_section_header(
      title: @user.full_name,
      scopes: UserProfilesHeaders.new.tabs(headers_policy.tabs, @user)
    )
  end
end
