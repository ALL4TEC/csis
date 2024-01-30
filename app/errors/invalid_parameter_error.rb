# frozen_string_literal: true

class InvalidParameterError < StandardError
  attr_reader :reason

  def initialize(parameter)
    super
    @reason = "Invalid parameter: #{parameter} given"
  end
end
