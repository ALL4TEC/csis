# frozen_string_literal: true

class BrandingPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      super_admin? ? scope.all : scope.none
    end
  end
end
