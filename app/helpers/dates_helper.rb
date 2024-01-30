# frozen_string_literal: true

require 'styles'

module DatesHelper
  def long(date)
    if I18n.locale == :en
      date.to_fs(:long_ordinal)
    else
      I18n.l date, format: :long
    end
  end
end
