# frozen_string_literal: true

class AssetPolicy < ApplicationPolicy
  def permitted_attributes
    [:name, :description, :category, :os, :confidentiality, :integrity, :availability,
     :account_id, { project_ids: [], target_ids: [] }]
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

  def all_targets?
    staff?
  end

  def create_target?
    staff?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if super_admin?
        scope.all
      elsif staff?
        user.staff_assets.with_discarded
      elsif contact?
        user.contact_assets
      end
    end

    def list_includes
      %i[projects targets]
    end
  end

  class Headers < ApplicationPolicy::Headers
    private

    def member_actions
      filter_available(%i[create_target edit])
    end

    def collection_actions
      filter_available(%i[new all_targets])
    end

    def member_other_actions
      filter_available(%i[destroy])
    end

    def collection_other_actions
      []
    end

    def member_tabs
      %i[overview targets]
    end

    def collection_tabs
      staff? ? %i[all trashed] : %i[all]
    end
  end
end
