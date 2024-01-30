# frozen_string_literal: true

class StaffPolicy < UserPolicy
  include CyberPolicy

  def permitted_attributes
    [:full_name, :email, :notification_email, :language_id, :send_confirmation_notification,
     { staff_team_ids: [], role_ids: [] }]
  end

  class Scope < Scope
    def resolve
      scope = if staff?
                if administrator? || cyber_admin?
                  User.staffs.with_discarded
                else
                  user.staff_colleagues
                end
              else
                user.contact_projects_staffs
              end
      scope.ordered_alphabetically
    end

    def list_includes
      %i[roles]
    end
  end

  class Headers < UserPolicy::Headers
  end
end
