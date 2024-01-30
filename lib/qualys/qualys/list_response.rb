# frozen_string_literal: true

class Qualys::ListResponse
  attr_reader :data

  def initialize(response, base_xpath, &block)
    if base_xpath.nil?
      @data = response.map(&block)
    elsif (@data = response.xpath(base_xpath).map(&block))
      # Lint/EmptyConditionalBody
    end
  end
end
