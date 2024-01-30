# frozen_string_literal: true

class JiraConfigPredicate
  class << self
    def expired?(config)
      config.expiration_date < DateTime.current
    end

    def expires_soon?(config)
      config.expiration_date < DateTime.current.advance(months: 1)
    end
  end
end
