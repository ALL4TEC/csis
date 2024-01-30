# frozen_string_literal: true

# Must add an over module as Staff and Contact are already defined as models
class Group::Contact::RolePolicy < ApplicationPolicy
  def disabled?
    !staff? && @user.roles.of_contacts.minimum(:priority) == @record.priority
  end

  class Scope < Scope
    def resolve
      scope.of_contacts
    end
  end
end
