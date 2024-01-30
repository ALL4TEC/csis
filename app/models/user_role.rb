# frozen_string_literal: true

class UserRole < ApplicationRecord
  self.table_name = 'users_roles'

  belongs_to :user,
    class_name: 'User',
    # inverse_of: :users_roles,
    primary_key: :id

  belongs_to :role,
    class_name: 'Role',
    # inverse_of: :users_roles,
    primary_key: :id
end
