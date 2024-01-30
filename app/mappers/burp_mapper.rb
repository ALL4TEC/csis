# frozen_string_literal: true

class BurpMapper
  SEVERITIES = {
    Information: :trivial,
    Low: :low,
    Medium: :medium,
    High: :high
  }.freeze

  class << self
    def map_kind(issue)
      severity = issue.severity
      confidence = issue.confidence
      tentative = confidence == 'Tentative'
      if severity == 'Information'
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

    def map_severity(issue)
      SEVERITIES[issue.severity.to_sym]
    end
  end
end
