# frozen_string_literal: true

module JobsHelper
  JOB_DATA = {
    completed: {
      icon: :check,
      color: :success
    },
    error: {
      icon: :close,
      color: :danger
    }
  }.freeze

  def job_icon(status)
    if status.to_sym.in?(JOB_DATA.keys)
      JOB_DATA[status.to_sym][:icon]
    else
      :pending
    end
  end

  def job_color(status)
    if status.to_sym.in?(JOB_DATA.keys)
      JOB_DATA[status.to_sym][:color]
    else
      :warning
    end
  end
end
