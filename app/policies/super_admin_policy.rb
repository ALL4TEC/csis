# frozen_string_literal: true

# Policy limiting content only to super admin users
class SuperAdminPolicy < ApplicationPolicy
  def list?
    super_admin?
  end

  def index?
    super_admin?
  end

  def new?
    super_admin?
  end

  def create?
    new?
  end

  def show?
    super_admin?
  end

  def edit?
    super_admin?
  end

  def update?
    edit?
  end

  def destroy?
    super_admin?
  end

  class Scope < Scope
    def resolve
      super_admin? ? scope.all : scope.none
    end
  end
end
