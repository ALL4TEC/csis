# frozen_string_literal: true

class AggregateReference < ApplicationRecord
  self.table_name = :aggregates_references

  belongs_to :aggregate,
    class_name: 'Aggregate',
    inverse_of: :aggregate_references,
    primary_key: :id

  belongs_to :reference,
    class_name: 'Reference',
    inverse_of: :aggregate_references,
    primary_key: :id
end
