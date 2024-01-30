# frozen_string_literal: true

module StatisticsHelper
  ICONS_D = {
    vulnerabilities: :vulnerabilities,
    scores: :statistics
  }.freeze

  def level_color(level)
    Aggregate.severities.keys.reverse[Statistic.current_levels[level.to_s.sub('nof_', '')]]
  end

  def stats_icon(symbol)
    ICONS_D[symbol]
  end
end
