# frozen_string_literal: true

module MfaPolicy
  extend ActiveSupport::Concern

  included do
    def force_mfa?
      !@record.parent_otp_mandatory? && !@record.otp_mandatory && super_admin?
    end

    def unforce_mfa?
      !@record.parent_otp_mandatory? && @record.otp_mandatory && super_admin?
    end
  end
end
