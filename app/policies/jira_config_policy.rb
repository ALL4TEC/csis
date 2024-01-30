# frozen_string_literal: true

class JiraConfigPolicy < ApplicationPolicy
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
    staff? && super_admin?
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
    [:name, :url, :project_id, :context, { supplier_ids: [] }]
  end

  class Scope < Scope
    def resolve
      if super_admin?
        JiraConfig.all
      else
        # Means an account that would have been created by a super_admin
        # at some time but who would not be super_admin more recently
        user.created_accounts.jira_configs
      end
    end
  end
end
