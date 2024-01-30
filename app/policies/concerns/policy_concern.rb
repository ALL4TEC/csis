# frozen_string_literal: true

class PolicyConcern
  attr_reader :user

  def initialize(user)
    raise Pundit::NotAuthorizedError, 'must be logged in' unless user

    @user = user
  end

  private

  # Affectation des rôles Staff
  # 'super_admin', 'cyber_admin', 'contact_admin'
  # Affectation des rôles Contacts
  # 'contact_admin', 'contact_manager'
  # Deprecated
  # def init_roles
  #   @role_super_admin = user.has_role?(:super_admin)
  #   @role_cyber_admin = user.has_role?(:cyber_admin)
  #   @role_contact_admin = user.has_role?(:contact_admin)
  #   @role_contact_client_owner = false
  #   return unless contact?

  #   @role_contact_client_owner = user.clients.kept.any? { |cli| cli.projects.count.positive? }
  # end

  def staff?
    user.staff?
  end

  def contact?
    user.contact?
  end

  def super_admin?
    user.super_admin?
  end

  # In prevision to futur administrator role
  # For the moment, part of super_admin
  def administrator?
    user.super_admin?
  end

  def cyber_admin?
    user.cyber_admin?
  end

  def contact_admin?
    user.contact_admin?
  end

  def contact_client_owner?
    user.contact_client_owner?
  end
end
