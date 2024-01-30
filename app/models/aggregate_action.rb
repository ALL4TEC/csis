# frozen_string_literal: true

class AggregateAction < ApplicationRecord
  self.table_name = :aggregates_actions

  belongs_to :aggregate,
    class_name: 'Aggregate',
    inverse_of: :aggregate_actions,
    primary_key: :id

  belongs_to :action,
    class_name: 'Action',
    inverse_of: :aggregate_actions,
    primary_key: :id
end
