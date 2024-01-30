# frozen_string_literal: true

class MissingRequiredParameterError < StandardError
  attr_reader :reason

  def initialize(method_name)
    super
    @reason = "Missing required parameter for #{method_name}"
  end
end
