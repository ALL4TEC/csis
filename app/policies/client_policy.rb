# frozen_string_literal: true

class ClientPolicy < GroupPolicy
  include RemediationPolicy

  def permitted_attributes
    [:ref_identifier, :name, :web_url, :internal_type, { contact_ids: [] }]
  end

  # Check if contact_ids is not empty if contact?
  def contacts_valid?(params)
    staff? || (contact? && params[:client][:contact_ids].compact_blank.blank?)
  end

  class Scope < Scope
    def resolve
      if super_admin? || contact_admin?
        scope.with_discarded
      elsif staff?
        user.staff_projects_clients.kept
      elsif contact?
        user.contact_clients.kept
      end
    end

    def show_includes
      [{ contacts: :roles }]
    end

    # Calls show at end
    def restore_includes
      show_includes
    end

    def edit_includes
      []
    end

    # Move to index
    def destroy_includes
      []
    end

    # Can call edit if error or show if success
    # No need to include show_includes
    def update_includes
      edit_includes
    end
  end

  class Headers < CredPolicy::Headers
  end
end
