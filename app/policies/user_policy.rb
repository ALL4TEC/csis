# frozen_string_literal: true

class UserPolicy < AdminPolicy
  include MfaPolicy

  # Discardable
  def destroy?
    admin_and_not_self_and_not_discarded?
  end

  def restore?
    admin_and_not_self_and_discarded?
  end

  # Activable
  def deactivate?
    admin_and_not_self_and_not_discarded? && !@record.inactif?
  end

  def activate?
    admin_and_not_self_and_not_discarded? && !@record.actif?
  end

  # Confirmable
  # Si confirmation déjà envoyée
  def resend_confirmation?
    admin_and_not_self_and_not_discarded? &&
      (!@record.confirmed? || @record.pending_reconfirmation?) &&
      @record.confirmation_sent_at.present?
  end

  def force_update_email?
    administrator_and_not_self_and_not_discarded? && @record.actif?
  end

  def force_confirm?
    administrator_and_not_self_and_not_discarded? && !@record.confirmed? && @record.actif?
  end

  # Recoverable
  def send_reset_password?
    admin_and_not_self_and_not_discarded?
  end

  def force_reset_password?
    administrator_and_not_self_and_not_discarded? && @record.actif?
  end

  # Lockable
  def send_unlock?
    admin_and_not_self_and_not_discarded? && @record.access_locked?
  end

  def force_unlock?
    administrator_and_not_self_and_not_discarded? && @record.access_locked?
  end

  # Otpable
  def force_direct_otp?
    admin_and_not_self_and_not_discarded? && @record.otp_activated? && @record.totp_enabled?
  end

  def force_deactivate_otp?
    administrator_and_not_self_and_not_discarded? && @record.otp_activated?
  end

  def force_unlock_otp?
    administrator_and_not_self_and_not_discarded? && @record.max_login_attempts?
  end

  # Gpgable
  def public_key?
    true
  end

  def administrator_and_not_self_and_not_discarded?
    !self? && !@record.discarded? && administrator?
  end

  def admin_and_not_self_and_not_discarded?
    !self? && not_discarded_and_admin?
  end

  def admin_and_not_self_and_discarded?
    !self? && discarded_and_admin?
  end

  def admin?
    if @record.staff?
      cyber_admin? || administrator?
    elsif @record.contact?
      contact_admin? || administrator?
    else
      administrator?
    end
  end

  class Scope < Scope
    def resolve
      scope = if super_admin?
                User.all
              else
                user.relations
              end
      scope.ordered_alphabetically
    end

    def list_includes
      %i[roles]
    end
  end

  class Headers < CredPolicy::Headers
  end
end
