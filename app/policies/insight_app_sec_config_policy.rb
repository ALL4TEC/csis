# frozen_string_literal: true

class InsightAppSecConfigPolicy < SuperAdminPolicy
  def import_scans?
    super_admin?
  end

  def update_scans?
    super_admin?
  end

  def delete_scan?
    super_admin?
  end

  def permitted_attributes
    [:name, :url, :api_key, { team_ids: [] }]
  end
end
