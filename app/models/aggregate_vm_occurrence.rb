# frozen_string_literal: true

class AggregateVmOccurrence < ApplicationRecord
  self.table_name = :aggregates_vm_occurrences

  belongs_to :aggregate,
    class_name: 'Aggregate',
    inverse_of: :aggregate_vm_occurrences,
    primary_key: :id

  belongs_to :vm_occurrence,
    class_name: 'VmOccurrence',
    inverse_of: :aggregate_vm_occurrences,
    primary_key: :id
end
