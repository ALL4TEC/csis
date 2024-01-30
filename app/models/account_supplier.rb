# frozen_string_literal: true

class AccountSupplier < ApplicationRecord
  self.table_name = 'accounts_suppliers'

  belongs_to :account,
    class_name: 'Account',
    inverse_of: :accounts_suppliers,
    primary_key: :id

  belongs_to :supplier,
    class_name: 'Client',
    inverse_of: :accounts_suppliers,
    primary_key: :id
end
