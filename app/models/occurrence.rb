# frozen_string_literal: true

# Common occurrences content
class Occurrence < ApplicationRecord
  self.abstract_class = true

  before_destroy do
    NotificationService.clear_related_to(self)
  end

  # @param aggregates_ary: [Aggregate]
  def add_aggregates(aggregates_ary)
    self.aggregates += aggregates_ary
    save!
  end

  # @param **occurrence:** Occurrence to compare with
  # @return occurrences vulnerability_id equality as boolean
  def same_vulnerability?(occurrence)
    vulnerability_id == occurrence.vulnerability_id
  end

  # Compare 2 vm_occurrences
  def equals?(occurrence)
    OccurrenceComparator.equal?(self, occurrence)
  end

  def similar?(occurrence)
    OccurrenceComparator.similar?(self, occurrence)
  end

  def to_s
    vulnerability.title
  end
end
