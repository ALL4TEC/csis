# frozen_string_literal: true

class NotePolicy < ApplicationPolicy
  def permitted_attributes
    %i[title content]
  end

  def index?
    staff?
  end

  def show?
    staff?
  end

  def new?
    staff?
  end

  def edit?
    staff? && !@record.discarded?
  end

  def autosave?
    staff? && !@record.discarded?
  end

  def destroy?
    staff? && !@record.discarded?
  end

  def restore?
    staff? && @record.discarded?
  end

  class Scope < Scope
    def resolve
      if staff?
        user.staff_notes
      else
        scope.none
      end
    end

    def list_includes
      []
    end

    def show_includes
      []
    end

    def edit_includes
      []
    end

    def destroy_includes
      []
    end

    def restore_includes
      []
    end
  end

  class Headers < ApplicationPolicy::Headers
    private

    def member_actions
      filter_available(%i[edit])
    end

    def member_other_actions
      filter_available(%i[destroy])
    end

    def member_tabs
      []
    end

    def collection_actions
      filter_available(%i[new])
    end

    def collection_other_actions
      []
    end

    def collection_tabs
      []
    end
  end
end
