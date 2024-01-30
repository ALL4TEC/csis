# frozen_string_literal: true

class ListFormatter
  class << self
    # @param **list_str:** String containing a #{separator} separated list
    # @param **separator:** Default to ','
    # @return list_str.split(separator).strip
    def to_ary(list_str, separator = ',')
      list_str.split(separator).flat_map(&:strip)
    end
  end
end
