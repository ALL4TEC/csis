# frozen_string_literal: true

require 'styles'

module ReportsHelper
  TRANSPARENCY_ICONS = {
    clearness: 'brightness_5',
    obfuscate: 'brightness_4',
    secretive: 'brightness_7'
  }.freeze

  def transparency_icon(state)
    TRANSPARENCY_ICONS[state.to_sym]
  end

  def report_icon(type)
    type.delete_suffix('Report').downcase.to_sym
  end
end
