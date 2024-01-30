# frozen_string_literal: true

class ScanImportPolicy < ApplicationPolicy
  def destroy?
    staff? && !@record.used_scans?
  end

  class Scope < Scope
    def resolve
      if staff?
        user.staff_viewable_scan_imports
      else
        scope.none
      end
    end
  end
end
