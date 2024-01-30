# frozen_string_literal: true

class IssuePolicy < ActionPolicy
  def permitted_attributes
    %i[resolved ticketable_id action_id id]
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all # TODO
    end
  end
end
