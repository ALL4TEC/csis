# frozen_string_literal: true

class ServicenowConfigPolicy < ApplicationPolicy
  def index?
    staff? && super_admin?
  end

  def show?
    staff? && super_admin?
  end

  def new?
    staff? && super_admin?
  end

  def edit?
    super_admin?
  end

  def update?
    edit?
  end

  # def activate?
  #   edit? && @record.discarded?
  # end

  # def deactivate?
  #   edit? && !@record.discarded?
  # end

  def destroy?
    edit? && !@record.any_action?
  end

  def permitted_attributes
    [:name, :url, :api_key, :secret_key, :fixed_vuln, :accepted_risk, { supplier_ids: [] }]
  end

  class Scope < Scope
    def resolve
      if super_admin?
        ServicenowConfig.all
      else
        user.created_accounts.servicenow_configs
      end
    end
  end
end
