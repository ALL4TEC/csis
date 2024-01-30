# frozen_string_literal: true

module GroupsConcern
  extend ActiveSupport::Concern

  included do
    # Actuellement dans le groupe group_name ?
    def currently_a?(group_name)
      current_group_name == group_name
    end

    def current_teams
      group_teams(current_user_group)
    end

    def current_dashboard_default_card
      current_user_group.dashboard_default_card
    end

    def update_current_dashboard_default_card(new_value)
      current_user_group.update(dashboard_default_card: new_value)
    end

    # Appartient au groupe ?
    def in_group?(group_name)
      group_name.in?(groups.map(&:name))
    end

    # Retourne les équipes liées à chaque groupe
    def group_teams(group_name)
      send(Group::USER_TEAMS[group_name.to_sym])
    end

    # Appartient au groupe des staffs?
    def member_of_staffs?
      in_group?('staff')
    end

    # Appartient au groupe des contacts?
    def member_of_contacts?
      in_group?('contact')
    end

    # Vue courante est de type 'Staff'
    def staff?
      currently_a?('staff')
    end

    # Vue courante est de type 'Contact'
    def contact?
      currently_a?('contact')
    end

    def super_admin?
      staff? && has_role?(:super_admin)
    end

    def cyber_admin?
      staff? && has_role?(:cyber_admin)
    end

    def contact_admin?
      has_role?(:contact_admin)
    end

    def switch_type(group)
      current_user_group.update(current: false)
      users_groups.where(group: group).update(current: true)
    end

    def active_for_authentication?
      super && actif? && current_group.present?
    end
  end
end
