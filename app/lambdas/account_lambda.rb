# frozen_string_literal: true

class AccountLambda
  class << self
    def only_active_scanners_of_kind(kind)
      lambda { |account|
        AccountPredicate.active?(account) &&
          AccountPredicate.scanner_of_kind?(account, kind)
      }
    end
  end
end
