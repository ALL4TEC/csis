# frozen_string_literal: true

class JobPolicy < ApplicationPolicy
  def index?
    super_admin?
  end

  def detail?
    super_admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all if super_admin?
    end
  end
end
