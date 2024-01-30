# frozen_string_literal: true

class RolePolicy < ApplicationPolicy
  include MfaPolicy

  class Scope < SuperAdminPolicy::Scope
  end
end
