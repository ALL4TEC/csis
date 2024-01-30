# frozen_string_literal: true

class Issue < ApplicationRecord
  self.table_name = :issues

  belongs_to :action,
    class_name: 'Action',
    inverse_of: :issues

  # TODO: le ticketable_type en BDD est pas bon (toujours Account)
  belongs_to :ticketable,
    polymorphic: true,
    inverse_of: :issues

  enum status: {
    not_created: 0,
    open: 1,
    closed: 2
  }, _suffix: true, _default: :not_created
end
