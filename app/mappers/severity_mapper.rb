# frozen_string_literal: true

class SeverityMapper
  class << self
    CVSS_TO_SEVERITY_DEFAULT = {
      low: 0.1,
      medium: 4.0,
      high: 7.0,
      critical: 9.0
    }.freeze

    # Takes the severity and returns a corresponding cvss level
    # from custom values if specified or default ones
    def cvss_level(severity)
      (Customization.get_value("cvss_to_severity_#{severity}") ||
       CVSS_TO_SEVERITY_DEFAULT[severity.to_sym]).to_f
    end

    # input: cvss score as number between 0 and 10
    # output: severity level as string
    def cvss_to_severity(cvss_score)
      %w[critical high medium low].each do |severity|
        return severity if cvss_score >= cvss_level(severity)
      end
      'trivial'
    end
  end
end
