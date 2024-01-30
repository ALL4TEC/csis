# frozen_string_literal: true

class Project::TeamPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    attr_reader :scope, :project

    def initialize(user, project, scope)
      super(user, scope)
      @project = project
    end

    def resolve
      scope.union_intersect(user.staff_teams, project.teams)
    end
  end
end
