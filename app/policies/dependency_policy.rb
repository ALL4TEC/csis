# frozen_string_literal: true

class DependencyPolicy < ApplicationPolicy
  def index?
    staff? || @record.aggregate.actions.where(receiver_id: user.id).present?
  end

  def create?
    staff?
  end

  def new?
    staff?
  end

  def updates?
    staff?
  end

  def permitted_attributes
    [{ predecessor_id: [] }]
  end

  class Scope < Scope
    def resolve
      scope.none
    end
  end

  class Headers < ApplicationPolicy::Headers
    private

    def collection_actions
      staff? ? %i[edit create_dependency] : []
    end

    def collection_other_actions
      staff? ? %i[destroy] : []
    end

    def collection_tabs
      %i[details dependencies]
    end
  end
end
