# frozen_string_literal: true

class ReportPolicy < ApplicationPolicy
  COMMON_PERMITTED_ATTRIBUTES = %i[
    title signatory_id introduction notes edited_at language_id addendum subtitle
  ].freeze

  def all?
    staff? || contact?
  end

  def index?
    staff? || contact_client_owner?
  end

  def show?
    staff? || contact_client_owner?
  end

  def new?
    staff?
  end

  def create?
    staff?
  end

  def edit?
    !@record.discarded? && staff?
  end

  def update?
    !@record.discarded? && staff?
  end

  def regenerate_scoring?
    !@record.discarded? && staff?
  end

  def destroy?
    !@record.discarded? && staff?
  end

  def restore?
    @record.discarded? && staff?
  end

  def notify?
    staff?
  end

  def auto_aggregate?
    !@record.discarded? && staff?
  end

  class Scope < Scope
    def resolve
      if staff?
        scope.in(user.staff_projects.flat_map { |p| p.reports.with_discarded.ids })
      else
        scope.in(user.contact_clients.clients.flat_map { |c| c.reports.ids })
      end
    end

    def list_includes
      [:language, :staff, :report_wa_scans, { wa_scans: :landing_page_attachment }] # staff
    end

    def all_includes
      list_includes << :project
    end

    def show_includes
      [{ vm_scans: :targets, wa_scans: :landing_page_attachment }]
    end

    def edit_includes
      [:wa_scans, { vm_scans: :targets }]
    end

    def update_includes
      [{ vm_scans: :targets }]
    end

    def regenerate_scoring_includes
      [{ vm_occurrences: %i[aggregate_vm_occurrences aggregates vulnerability],
         wa_occurrences: %i[aggregate_wa_occurrences aggregates vulnerability] }]
    end

    def destroy_includes
      []
    end

    def restore_includes
      []
    end

    def notify_includes
      []
    end

    def auto_aggregate_includes
      []
    end
  end

  class Headers < ApplicationPolicy::Headers
    ALL_ACTIONS = %i[
      create_aggregate export_as_pdf export_as_xlsx create_note import_scan launch_scan
      regenerate_scoring destroy
    ].freeze

    STAFF_TABS = %i[
      overview aggregates exports notes scan_imports scan_launches
    ].freeze

    CONTACT_TABS = %i[overview exports].freeze

    private

    def member_actions
      staff? ? %i[edit] : []
    end

    def member_other_actions
      staff? ? ALL_ACTIONS : []
    end

    def member_tabs
      staff? ? STAFF_TABS : CONTACT_TABS
    end
  end
end
