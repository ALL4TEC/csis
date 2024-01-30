# frozen_string_literal: true

class OccurrenceLambda
  class << self
    def only_same_vulnerability_kind(kind)
      ->(occ) { OccurrencePredicate.same_vulnerability_kind?(occ, kind) }
    end

    def only_new(old_occ)
      ->(occ) { OccurrencePredicate.not_in_list?(old_occ, occ) }
    end
  end
end
