# frozen_string_literal: true

require 'styles'

module AssetsHelper
  LEVELS_MAP = {
    high: 'critical',
    medium: 'medium',
    low: 'trivial'
  }.freeze

  def asset_level_color(level)
    LEVELS_MAP[level.to_sym]
  end
end
