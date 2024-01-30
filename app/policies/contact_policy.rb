# frozen_string_literal: true

class ContactPolicy < UserPolicy
  include RemediationPolicy

  def permitted_attributes
    [:ref_identifier, :full_name, :email, :notification_email, :language_id,
     :send_confirmation_notification, { contact_client_ids: [], role_ids: [] }]
  end

  class Scope < Scope
    # By default ordered alphabetically
    def resolve
      scope = if administrator? || contact_admin?
                User.contacts.with_discarded
              elsif staff?
                user.staff_projects_contacts.kept
              elsif contact?
                user.contact_colleagues.kept
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
