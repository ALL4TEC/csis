# frozen_string_literal: true

module OtpConcern
  extend ActiveSupport::Concern

  included do
    # 2FA
    def send_two_factor_authentication_code(code)
      CustomDeviseMailer.send_two_factor_authentication_code(self, code).deliver_later
      return unless ENV['RAILS_ENV'] == 'development'

      Rails.logger.info(">>>>>>>>>>>>>>> otp_secret_key: #{otp_secret_key}, otp_code: #{code}")
    end

    def need_two_factor_authentication?(_request)
      otp_activated?
    end

    def parent_otp_mandatory?
      groups.any?(&:otp_mandatory?) ||
        roles.any?(&:otp_mandatory?) ||
        staff_teams.any?(&:otp_mandatory?) ||
        contact_clients.any?(&:otp_mandatory?)
    end

    def otp_mandatory?
      parent_otp_mandatory? || otp_mandatory
    end

    # Implied if mandatory or manually activated
    def otp_activated?
      otp_mandatory? || otp_activated_at.present?
    end

    ### OTP service
    def setup_otp_authenticator
      update(otp_secret_key: generate_totp_secret,
        totp_configuration_token: generate_totp_configuration_unique_token)
    end

    def activate_otp
      update(otp_activated_at: Date.current)
    end

    def deactivate_otp
      update(otp_activated_at: nil)
    end

    def unlock_otp
      update(second_factor_attempts_count: 0)
    end

    def clear_otp_authenticator
      self.second_factor_attempts_count = nil
      self.encrypted_otp_secret_key = nil
      self.encrypted_otp_secret_key_iv = nil
      self.encrypted_otp_secret_key_salt = nil
      self.direct_otp = nil
      self.direct_otp_sent_at = nil
      self.totp_timestamp = nil
      self.direct_otp = nil
      self.otp_secret_key = nil
      save!
    end

    def generate_totp_configuration_unique_token
      tokn = SecureRandom.urlsafe_base64
      if User.exists?(totp_configuration_token: tokn)
        tokn = generate_totp_configuration_unique_token
      end
      tokn
    end

    def validate_totp_configuration
      update(totp_configuration_token: nil)
    end
  end
end
