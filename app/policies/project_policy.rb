# frozen_string_literal: true

class ProjectPolicy < ApplicationPolicy
  def permitted_attributes
    [:name, :client_id, :language_id, :auto_generate, :auto_export, :scan_regex,
     :report_auto_generation_cron, :auto_aggregate, :notification_severity_threshold,
     { team_ids: [], supplier_ids: [], asset_ids: [] }]
  end

  def index?
    staff? || contact?
  end

  def show?
    staff? || contact?
  end

  def trashed?
    staff?
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

  def regenerate_all_scoring?
    staff?
  end

  def destroy?
    !@record.discarded? && staff?
  end

  def restore?
    @record.discarded? && staff?
  end

  def admin?
    contact_admin? || administrator?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if staff?
        user.staff_projects.with_discarded
      elsif contact?
        if contact_client_owner?
          user.contact_kept_projects
        else
          user.contact_projects
        end
      end
    end

    def list_includes
      [:statistics, :client, :suppliances, :suppliers, :teams,
       { certificate: :certificates_languages }]
    end

    def unit_includes
      [{ reports: [:language, :report_wa_scans, { wa_scans: :landing_page_attachment }] }]
    end
  end

  class Headers < ApplicationPolicy::Headers
    private

    def report_actions
      available = %i[create_scan_report]
      available << :create_pentest_report if Rails.application.config.pentest_enabled
      available << :create_action_plan_report if Rails.application.config.action_plan_enabled
    end

    def report_other_actions
      filter_available(%i[edit regenerate_scoring destroy])
    end

    def report_tabs
      member_tabs
    end

    def member_actions
      filter_available(%i[edit])
    end

    def collection_actions
      filter_available(%i[new])
    end

    def member_other_actions
      filter_available(%i[regenerate_scoring destroy])
    end

    def collection_other_actions
      filter_available(%i[regenerate_all_scoring])
    end

    def member_tabs
      %i[overview reports statistics scheduled_scans]
    end

    def collection_tabs
      staff? ? %i[all trashed] : %i[all]
    end
  end
end
