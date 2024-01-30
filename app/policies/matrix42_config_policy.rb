# frozen_string_literal: true

class Matrix42ConfigPolicy < ApplicationPolicy
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

  def activate?
    edit? && @record.discarded?
  end

  def deactivate?
    edit? && !@record.discarded?
  end

  def destroy?
    edit? && !@record.any_action?
  end

  def permitted_attributes
    [:name, :url, :api_url, :default_ticket_type, :api_key, { supplier_ids: [] }]
  end

  class Scope < Scope
    def resolve
      if super_admin?
        Matrix42Config.all
      else
        user.created_accounts.matrix42_configs
      end
    end
  end
end
