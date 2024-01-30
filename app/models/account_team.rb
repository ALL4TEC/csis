# frozen_string_literal: true

class AccountTeam < ApplicationRecord
  self.table_name = 'accounts_teams'

  belongs_to :account,
    class_name: 'Account',
    inverse_of: :accounts_teams,
    primary_key: :id

  belongs_to :team,
    class_name: 'Team',
    inverse_of: :accounts_teams,
    primary_key: :id
end
