# frozen_string_literal: true

class ScanLaunchPolicy < ApplicationPolicy
  def index?
    staff?
  end

  def new?
    staff?
  end

  def zaproxy?
    staff?
  end

  def import?
    staff? && @record.done? && @record.result.present? && @record.report.present? &&
      @record.scanner.to_sym.in?(ScanConfiguration::IMPORTABLE_SCANNERS)
  end

  def destroy?
    staff? && @record.scan_import.blank?
  end

  def permitted_attributes
    [
      {
        scan_configuration_attributes: [
          :auto_import, :auto_aggregate, :auto_aggregate_mixing, :target, :scan_name, :scan_type,
          { parameters: [] }
        ]
      }
    ]
  end

  class Scope < Scope
    def resolve
      if staff?
        user.staff_viewable_scan_launches
      else
        scope.none
      end
    end
  end
end
