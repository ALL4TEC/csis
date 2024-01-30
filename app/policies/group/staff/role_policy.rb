# frozen_string_literal: true

# Must add an over module as Staff and Contact are already defined as models
class Group::Staff::RolePolicy < ApplicationPolicy
  def disabled?
    @user.roles.of_staffs.minimum(:priority) == @record.priority
  end

  class Scope < Scope
    def resolve
      if staff?
        if super_admin?
          scope.of_staffs
        elsif cyber_admin?
          scope.of_staffs.without_super
        end
      else
        scope.none # Contacts are not authorized to view staff roles
      end
    end
  end
end
