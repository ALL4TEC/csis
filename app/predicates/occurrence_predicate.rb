# frozen_string_literal: true

class OccurrencePredicate
  class << self
    def same_vulnerability_kind?(occ, kind)
      occ.vulnerability.kind == kind
    end

    def any_same_vulnerability?(occ_list, occu)
      occ_list.any? { |occ| occu.same_vulnerability?(occ) }
    end

    def any_similar?(occ_list, occu)
      occ_list.any? { |occ| occu.similar?(occ) }
    end

    def any_equal?(occ_list, occu)
      occ_list.any? { |occ| occu.equals?(occ) }
    end

    def not_in_list?(occ_list, occu)
      occ_list.all? { |occ| !occu.equals?(occ) }
    end
  end
end
