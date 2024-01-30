# frozen_string_literal: true

class AggregatePolicy < ApplicationPolicy
  def index?
    staff?
  end

  def new?
    staff?
  end

  def create?
    staff?
  end

  def show?
    staff?
  end

  def edit?
    staff?
  end

  def update?
    staff?
  end

  def up?
    staff?
  end

  def down?
    staff?
  end

  def toggle_visibility?
    staff?
  end

  def destroy?
    staff?
  end

  def edit_attachment?
    staff?
  end

  def update_attachment?
    staff?
  end

  def reorder?
    staff?
  end

  def save_order?
    staff?
  end

  def apply_order?
    staff?
  end

  def merge?
    staff?
  end

  def bulk_duplicate?
    staff?
  end

  def bulk_delete?
    staff?
  end

  def permitted_attributes
    [:title, :description, :solution, :scope, :severity, :status, :kind, :visibility,
     :impact, :complexity, { reference_ids: [], vm_occurrence_ids: [], wa_occurrence_ids: [] }]
  end

  class Scope < Scope
    def resolve
      if staff?
        scope.all
      else
        scope.none
      end
    end

    def list_includes
      [:actions, :aggregate_vm_occurrences, :aggregate_wa_occurrences,
       { vm_occurrences: :vulnerability, wa_occurrences: :vulnerability }]
    end

    def actions_index_includes
      [{ report: [{ project: :client }] }]
    end

    def actions_new_includes
      [{ report: [{ project: [
        { client: %i[client_contacts contacts], suppliers: %i[client_contacts contacts] }
      ] }] }]
    end

    def actions_create_includes
      [{ report: [{ project: [
        { client: %i[client_contacts contacts], suppliers: %i[client_contacts contacts] }
      ] }] }]
    end
  end
end
