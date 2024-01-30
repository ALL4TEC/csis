# frozen_string_literal: true

module ToastsHelper
  TOASTS_DATA = {
    info: {
      role: 'status',
      live: 'polite',
      bg: 'info',
      icon: :info
    },
    alert: {
      role: 'status',
      live: 'assertive',
      bg: 'danger',
      icon: :warning
    }
  }.freeze

  def self.toast_data(type)
    TOASTS_DATA[type]
  end

  def toast_data(type)
    ToastsHelper.toast_data(type)
  end
end
