# frozen_string_literal: true

class DateFormatter
  class << self
    # @param **date:** Date to format
    # @param **format:** Default to '%Y-%m-%d'
    # @return date.strftime(format)
    def to_ftime(date, format = '%Y-%m-%d')
      date.strftime(format)
    end
  end
end
