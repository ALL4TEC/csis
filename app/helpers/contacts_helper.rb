# frozen_string_literal: true

module ContactsHelper
  STATES_COLORS = {
    inactif: 'text-dark',
    en_cours: 'text-warning',
    actif: 'text-success'
  }.freeze

  def state_color(state)
    STATES_COLORS[state.to_sym]
  end

  def mail_placeholder
    'user@domain.com'
  end
end
