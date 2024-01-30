# frozen_string_literal: true

class ReportExportPolicy < ApplicationPolicy
  def index?
    staff? || contact_client_owner?
  end

  def create?
    staff?
  end

  def destroy?
    staff?
  end

  class Scope < Scope
    def resolve
      if staff?
        user.staff_viewable_exports
      else
        user.contact_viewable_exports
      end
    end
  end

  class Headers < ReportPolicy::Headers
    private

    def member_actions
      staff? ? %i[export_as_pdf export_as_xlsx] | super : []
    end

    def member_other_actions
      staff? ? %i[export_no_arch export_no_histo] | (super - %i[export_as_pdf export_as_xlsx]) : []
    end

    def member_tabs
      if staff?
        %i[overview aggregates exports notes scan_imports scan_launches]
      else
        %i[overview exports]
      end
    end
  end
end
