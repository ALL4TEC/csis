# frozen_string_literal: true

class ZaproxyMapper
  SEVERITIES = %i[trivial low medium high critical].freeze

  class << self
    # @param riskcode: integer
    # @param confidence: integer
    def map_kind(riskcode, confidence)
      tentative = confidence == 1
      if riskcode.zero?
        if tentative
          :vulnerability_or_potential_vulnerability
        else
          :information_gathered
        end
      elsif tentative
        :potential_vulnerability
      else
        :vulnerability
      end
    end

    # @param: riskcode integer
    def map_severity(riskcode)
      SEVERITIES[riskcode]
    end
  end
end
