# frozen_string_literal: true

class AggregateWaOccurrence < ApplicationRecord
  self.table_name = :aggregates_wa_occurrences

  belongs_to :aggregate,
    class_name: 'Aggregate',
    inverse_of: :aggregate_wa_occurrences,
    primary_key: :id

  belongs_to :wa_occurrence,
    class_name: 'WaOccurrence',
    inverse_of: :aggregate_wa_occurrences,
    primary_key: :id
end
