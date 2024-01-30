# frozen_string_literal: true

class TargetPolicy < ApplicationPolicy
  def permitted_attributes
    [:name, :kind, :category, :reference_id, :ip, :url, :availability,
     { asset_ids: [], vm_scans: [], wa_scans: [] }]
  end

  def index?
    staff? || contact?
  end

  def show?
    staff? || contact?
  end

  def trashed?
    staff?
  end

  def new?
    staff?
  end

  def create?
    staff?
  end

  def edit?
    !@record.discarded? && staff?
  end

  def update?
    !@record.discarded? && staff?
  end

  def destroy?
    !@record.discarded? && staff?
  end

  def restore?
    @record.discarded? && staff?
  end

  def admin?
    contact_admin? || administrator?
  end

  def all_assets?
    staff?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if super_admin?
        scope.all
      elsif staff?
        user.staff_targets.with_discarded
      elsif contact?
        user.contact_targets
      end
    end

    def list_includes
      %i[assets vm_scans wa_scans]
    end

    def all_includes
      list_includes
    end
  end

  class Headers < ApplicationPolicy::Headers
    private

    def member_actions
      filter_available(%i[edit])
    end

    def collection_actions
      filter_available(%i[all_assets])
    end

    def member_other_actions
      filter_available(%i[destroy])
    end

    def collection_other_actions
      []
    end

    def member_tabs
      []
    end

    def collection_tabs
      []
    end
  end
end
