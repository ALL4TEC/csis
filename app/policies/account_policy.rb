# frozen_string_literal: true

class AccountPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if staff?
        user.accounts
      else
        scope.none
      end
    end
  end
end
