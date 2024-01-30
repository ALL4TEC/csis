# frozen_string_literal: true

class ScheduledScanPolicy < ApplicationPolicy
  def index?
    staff?
  end

  def new?
    staff?
  end

  def zaproxy?
    staff?
  end

  def activate?
    staff? && @record.discarded?
  end

  def deactivate?
    staff? && !@record.discarded?
  end

  def destroy?
    staff? && @record.scan_launches.count.zero?
  end

  def permitted_attributes
    [
      :scheduled_scan_cron, :report_action,
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
        user.staff_viewable_scheduled_scans
      else
        scope.none
      end
    end
  end

  class Headers < ApplicationPolicy::Headers
    private

    def member_actions
      %i[schedule_scan]
    end

    def member_other_actions
      filter_available(%i[edit regenerate_scoring destroy])
    end

    def member_tabs
      %i[overview reports statistics scheduled_scans]
    end
  end
end
