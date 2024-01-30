# frozen_string_literal: true

class TeamPolicy < GroupPolicy
  include CyberPolicy

  def permitted_attributes
    [:name, :qualys_config_id, { staff_ids: [] }]
  end

  class Scope < Scope
    def resolve
      if staff?
        if super_admin? || cyber_admin?
          scope.with_discarded
        else
          user.staff_teams
        end
      else
        scope.none
      end
    end

    def list_includes
      %i[staffs_teams staffs projects]
    end
  end

  class Headers < CredPolicy::Headers
  end
end
