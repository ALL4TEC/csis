# frozen_string_literal: true

class AccountPredicate
  AVAILABLE_SCANNERS = {
    vm: %w[CyberwatchConfig QualysConfig],
    wa: %w[QualysConfig]
  }.freeze

  class << self
    def active?(account)
      !account.discarded?
    end

    # @return if account.type is in available scanners configurations of kind
    def scanner_of_kind?(account, kind)
      account.type.in?(AVAILABLE_SCANNERS[kind])
    end
  end
end
