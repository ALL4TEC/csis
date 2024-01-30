# frozen_string_literal: true

class CyberwatchConfigPolicy < SuperAdminPolicy
  def scans_import?
    super_admin?
  end

  def scans_update?
    super_admin?
  end

  def vulnerabilities_import?
    super_admin?
  end

  def assets_import?
    super_admin?
  end

  def scan_delete?
    super_admin?
  end

  def ping?
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
    [:name, :url, :verify_ssl_certificate, :kind, :api_key, :secret_key, :vm_import_cron,
     { team_ids: [] }]
  end

  def permitted_scans_attributes
    %i[name created_at]
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if super_admin?
        scope.all
      elsif staff?
        user.cyberwatch_configs
      end
    end
  end
end
