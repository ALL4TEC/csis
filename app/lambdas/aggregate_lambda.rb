# frozen_string_literal: true

class AggregateLambda
  class << self
    def only_similar_occurrence(aggregate, kind)
      ->(occ) { AggregatePredicate.any_similar_occurrence?(aggregate, kind, occ) }
    end

    def only_same_vulnerability_occurrence(aggregate, kind)
      ->(occ) { AggregatePredicate.any_same_vulnerability_occurrence?(aggregate, kind, occ) }
    end
  end
end
