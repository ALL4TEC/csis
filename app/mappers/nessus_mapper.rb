# frozen_string_literal: true

class NessusMapper
  class << self
    def map_kind(report_item)
      severity = report_item.severity
      risk_factor = report_item.risk_factor
      if severity.to_i.zero?
        if risk_factor.in?(%w[High Critical])
          :vulnerability_or_potential_vulnerability
        else
          :information_gathered
        end
      elsif risk_factor.in?(%w[None Low Medium])
        :potential_vulnerability
      else
        :vulnerability
      end
    end

    def map_severity(report_item)
      Vulnerability.severities.keys[report_item.severity.to_i]
    end
  end
end
