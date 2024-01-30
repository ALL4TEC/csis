# frozen_string_literal: true

class QualysVmClientPolicy < SuperAdminPolicy
  def permitted_attributes
    [:qualys_id, :qualys_name, :qualys_config_id, { team_ids: [] }]
  end

  class Scope < SuperAdminPolicy::Scope
    def list_includes
      %i[teams qualys_config vm_scans]
    end
  end
end
