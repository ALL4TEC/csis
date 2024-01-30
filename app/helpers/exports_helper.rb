# frozen_string_literal: true

module ExportsHelper
  EXPORT_DATA = {
    scheduled: {
      icon: :schedule,
      color: :secondary
    },
    processing: {
      icon: :pending,
      color: :warning
    },
    generated: {
      icon: :check,
      color: :success
    },
    errored: {
      icon: :close,
      color: :danger
    }
  }.freeze

  def export_icon(status)
    if status.to_sym.in?(EXPORT_DATA.keys)
      EXPORT_DATA[status.to_sym][:icon]
    else
      :pending
    end
  end

  def export_color(status)
    if status.to_sym.in?(EXPORT_DATA.keys)
      EXPORT_DATA[status.to_sym][:color]
    else
      :warning
    end
  end
end
