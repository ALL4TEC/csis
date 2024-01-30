# frozen_string_literal: true

class ReportPredicate
  class << self
    # Check if intersection of occurrence aggregates and current report aggregates
    # is present
    def aggregated?(report, occurrence)
      (occurrence.aggregates & report.aggregates).present?
    end

    # Check if report related aggregates of occurrence is not false positive
    def not_false_positive_aggregate?(report, occurrence)
      agg = occurrence.aggregates.find_by(report: report)
      agg.present? ? !agg.falsepositive_severity? : false
    end
  end
end
