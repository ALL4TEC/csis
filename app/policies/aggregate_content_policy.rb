# frozen_string_literal: true

class AggregateContentPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if staff?
        user.staff_viewable_contents
      else
        scope.none
      end
    end
  end
end
