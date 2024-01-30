# frozen_string_literal: true

class UserGroup < ApplicationRecord
  self.table_name = 'users_groups'

  belongs_to :user,
    class_name: 'User',
    inverse_of: :users_groups,
    primary_key: :id

  belongs_to :group,
    class_name: 'Group',
    inverse_of: :users_groups,
    primary_key: :id

  before_destroy do
    if current
      # Setting first other group as current
      others_user_groups = UserGroup.where(user: user)
      others_user_groups.first.update(current: true) if others_user_groups.present?
    end
  end
end
