# frozen_string_literal: true

class User::ProfilePolicy < ApplicationPolicy
  def setup_otp_authenticator?
    @record.otp_activated? && !@record.totp_enabled?
  end

  def resetup_otp_authenticator?
    @record.otp_activated? && @record.totp_enabled?
  end

  def clear_otp_authenticator?
    @record.otp_activated? && @record.totp_enabled?
  end

  def activate_otp?
    !@record.otp_activated?
  end

  def deactivate_otp?
    @record.otp_activated? && !@record.otp_mandatory?
  end

  def configure_totp?
    @record.otp_activated? && @record.totp_enabled? && @record.totp_configuration_token.present?
  end

  def test_totp_configuration?
    @record.otp_activated? && @record.totp_enabled?
  end

  def permitted_password_attributes
    %i[current_password password password_confirmation]
  end

  def permitted_public_key_attributes
    %i[public_key]
  end

  def permitted_display_attributes
    %i[display_submenu_direction]
  end

  def permitted_notifications_attributes
    [
      accounts_users_attributes: [:id, :channel_id, { notify_on: [] }],
      send_mail_on: [], notify_on: []
    ]
  end

  class Headers < ApplicationPolicy::Headers
    private

    def member_tabs
      %i[overview edit_password edit_public_key edit_otp edit_display edit_notifications]
    end
  end
end
