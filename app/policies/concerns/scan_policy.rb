# frozen_string_literal: true

class ScanPolicy < ApplicationPolicy
  def show?
    staff?
  end

  def launch?
    staff?
  end

  def show_occurrence?
    staff?
  end

  class Scope < Scope
    def initialize(user, scope)
      # Extract kind from (Vm|Wa)ScanPolicy::Scope
      @kind = super.kind_accro
      super(user, scope)
    end

    def resolve
      if staff?
        if super_admin?
          scope.all
        else
          user.send(:"#{@kind}_scans")
        end
      elsif contact?
        scope.none
      end
    end
  end
end
