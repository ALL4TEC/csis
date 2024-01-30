# frozen_string_literal: true

class QualysConfigPolicy < SuperAdminPolicy
  def new_client?
    @record.ext.consultants_kind? && super_admin?
  end

  def wa_scans_import?
    super_admin?
  end

  def vm_scans_import?
    super_admin?
  end

  def vm_scans_update?
    super_admin?
  end

  def wa_scans_update?
    super_admin?
  end

  def vulnerabilities_import?
    super_admin?
  end

  def vm_scan_delete?
    super_admin?
  end

  def wa_scan_delete?
    super_admin?
  end

  def activate?
    super_admin? && @record.discarded?
  end

  def deactivate?
    super_admin? && !@record.discarded?
  end

  def destroy?
    super_admin? && !@record.any_scan?
  end

  def permitted_attributes
    [:name, :url, :kind, :login, :password, :vm_import_cron, :wa_import_cron, { team_ids: [] }]
  end

  def permitted_wa_scans_attributes
    [:name, :created_at, :reference, :thumb_only, :force, { qualys_wa_client_ids: [] }]
  end

  def permitted_vm_scans_attributes
    [:name, :created_at, { qualys_vm_client_ids: [] }]
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if super_admin?
        scope.all
      elsif staff?
        user.qualys_configs
      end
    end
  end
end
