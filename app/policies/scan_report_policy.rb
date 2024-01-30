# frozen_string_literal: true

class ScanReportPolicy < ReportPolicy
  def permitted_update_attributes
    COMMON_PERMITTED_ATTRIBUTES + [
      :client_logo, :org_introduction, :vm_introduction, :wa_introduction,
      { vm_scan_ids: [], wa_scan_ids: [], contact_ids: [] }
    ]
  end

  def permitted_create_attributes
    permitted_update_attributes << :base_report_id
  end
end
