# frozen_string_literal: true

class AggregatePredicate
  class << self
    def same_id?(aggregate_one, aggregate_two)
      aggregate_one.id == aggregate_two.id
    end

    def same_report?(aggregate_one, aggregate_two)
      aggregate_one.report_id == aggregate_two.report_id
    end

    def same_kind?(aggregate_one, aggregate_two)
      aggregate_one.kind == aggregate_two.kind
    end

    def any_equal_occurrence?(aggregate, kind, occu)
      OccurrencePredicate.any_equal?(aggregate.send(:"#{kind}_occurrences"), occu)
    end

    def any_similar_occurrence?(aggregate, kind, occu)
      OccurrencePredicate.any_similar?(aggregate.send(:"#{kind}_occurrences"), occu)
    end

    def any_same_vulnerability_occurrence?(aggregate, kind, occu)
      OccurrencePredicate.any_same_vulnerability?(aggregate.send(:"#{kind}_occurrences"), occu)
    end
  end
end
