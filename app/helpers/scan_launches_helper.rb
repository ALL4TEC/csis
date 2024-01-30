# frozen_string_literal: true

require 'styles'

module ScanLaunchesHelper
  BOOL_DATA = {
    true => {
      color: 'success',
      icon: :check
    },
    false => {
      color: 'danger',
      icon: :close
    }
  }.freeze

  # flag is a boolean symbol
  def bool_data(flag)
    BOOL_DATA[flag]
  end
end
