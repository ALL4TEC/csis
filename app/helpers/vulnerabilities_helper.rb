# frozen_string_literal: true

module VulnerabilitiesHelper
  KIND_MAP = {
    information_gathered: { icon: 'info', color: 'muted' },
    vulnerability: { icon: 'security', color: 'black' },
    potential_vulnerability: { icon: 'security', color: 'muted' },
    vulnerability_or_potential_vulnerability: { icon: 'info', color: 'black' }
  }.freeze

  def kind_icon(state)
    KIND_MAP[state.to_sym][:icon]
  end

  def kind_color(state)
    KIND_MAP[state.to_sym][:color]
  end

  def self.kind_icon(state)
    KIND_MAP[state.to_sym][:icon]
  end

  def self.kind_color(state)
    KIND_MAP[state.to_sym][:color]
  end
end
