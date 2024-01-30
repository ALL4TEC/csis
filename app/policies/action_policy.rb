# frozen_string_literal: true

class ActionPolicy < ApplicationPolicy
  def index?
    staff?
  end

  def show?
    cond = staff?
    cond ||= @record.client.contacts.ids.include?(@user.id)
    cond ||= @record.receiver_id == @user.id
    cond
  end

  def create?
    staff?
  end

  def new?
    create?
  end

  def update?
    staff?
  end

  def edit?
    update?
  end

  def destroy?
    staff?
  end

  def restore?
    staff?
  end

  def trashed?
    restore?
  end

  def bulk_delete?
    destroy?
  end

  def bulk_mail?
    staff?
  end

  def bulk_state_update?
    return true unless contact?

    @record.state.to_sym.in?(permitted_contact_states)
  end

  def comment?
    staff? || contact?
  end

  def active?
    staff? || contact?
  end

  def clotured?
    staff? || contact?
  end

  def archived?
    staff? || contact?
  end

  def permitted_contact_states
    %i[assigned fixed_vulnerability accepted_risk_not_fixed not_fixed]
  end

  def permitted_states_select
    among = contact? ? permitted_contact_states : Action.states.keys.map(&:to_sym)
    @record.states_select(among)
  end

  def permitted_attributes
    [:author_id, :name, :description, :pmt_name, :receiver_id, :due_date, :priority,
     { aggregate_ids: [] }, { ticketable_ids: [] }]
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if contact?
        # Les actions à corriger du user
        ids = user.received_actions.to_correct.ids
        # + les actions à corriger des équipes de remédiation propriétaires
        ids |= user.contact_clients.clients.flat_map { |c| c.actions.to_correct.ids }
      else
        ids = user.staff_projects.flat_map { |p| p.actions.with_discarded.ids }
      end
      scope.with_discarded.in(ids) # Nécessaire car ransack ne fonctionne pas sur une array
    end

    def list_includes
      [:receiver, { aggregates: :report }]
    end

    def active_includes
      [list_includes]
    end

    def archived_includes
      list_includes
    end

    def clotured_includes
      list_includes
    end

    def trashed_includes
      %i[receiver aggregates]
    end

    def show_includes
      [{ aggregates: :report }] if contact?
    end

    def update_includes
      [{ aggregates: :report }] if contact?
    end

    def restore_includes
      []
    end

    def destroy_includes
      []
    end

    def comment_includes
      []
    end

    def edit_includes
      [{
        aggregates:
        [{
          report:
          [{
            project:
            [{ client: %i[client_contacts contacts], suppliers: %i[client_contacts contacts] }]
          }]
        }]
      }]
    end
  end

  class Headers < ApplicationPolicy::Headers
    private

    def list_tabs
      filter_available(%i[active clotured archived trashed])
    end

    def member_tabs
      %i[details dependencies]
    end

    def member_actions
      filter_available(%i[edit])
    end

    def member_other_actions
      filter_available(%i[destroy])
    end
  end
end
