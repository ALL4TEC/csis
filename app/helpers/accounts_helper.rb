# frozen_string_literal: true

module AccountsHelper
  ACTIVE_DATA = {
    false => { color: 'danger', text: 'accounts.labels.inactive' },
    true => { color: 'success', text: 'accounts.labels.active' }
  }.freeze

  def active_color(active)
    ACTIVE_DATA[active][:color]
  end

  def active_text(active)
    I18n.t(ACTIVE_DATA[active][:text])
  end
end
