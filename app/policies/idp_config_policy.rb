# frozen_string_literal: true

class IdpConfigPolicy < SuperAdminPolicy
  def permitted_attributes
    %i[name idp_metadata_url idp_entity_id idp_metadata_xml]
  end

  def activate?
    super_admin_and_not_discarded? && !@record.active
  end

  def deactivate?
    super_admin_and_not_discarded? && @record.active
  end

  def destroy?
    super_admin? && !@record.discarded?
  end

  def restore?
    super_admin? && @record.discarded?
  end

  def super_admin_and_not_discarded?
    super_admin? && !@record.discarded?
  end

  class Scope < Scope
    def resolve
      if super_admin?
        scope.with_discarded
      else
        scope.none
      end
    end

    def list_includes
      %i[users_roles roles]
    end
  end

  class Headers < CredPolicy::Headers
  end
end
