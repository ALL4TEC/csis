# frozen_string_literal: true

class ActionPlanReportPolicy < ReportPolicy
  def permitted_update_attributes
    COMMON_PERMITTED_ATTRIBUTES + [
      :client_logo, :purpose, :org_introduction,
      { contact_ids: [], report_action_import: :document }
    ]
  end

  def permitted_create_attributes
    permitted_update_attributes + [:base_report_id]
  end

  def index?
    staff?
  end

  class Scope < Scope
    def action_plans_includes
      []
    end

    def index
      []
    end
  end

  class Headers < Headers
    private

    def member_other_actions
      all = %i[
        create_aggregate export_as_pdf export_as_xlsx create_note regenerate_scoring destroy
      ]
      staff? ? all : []
    end

    def member_tabs
      staff? ? %i[overview aggregates action_plans exports notes] : %i[overview]
    end
  end
end
