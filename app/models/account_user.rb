# frozen_string_literal: true

class AccountUser < ApplicationRecord
  self.table_name = 'accounts_users'

  belongs_to :account,
    class_name: 'Account',
    inverse_of: :accounts_users,
    primary_key: :id

  belongs_to :user,
    class_name: 'User',
    inverse_of: :accounts_users,
    primary_key: :id

  scope :active, -> { where.not(channel_id: [nil, '']) }

  def provider
    account.type.delete_suffix('Config').underscore.to_sym
  end
end
