# frozen_string_literal: true

class MethodNotAllowedError < StandardError
  attr_reader :reason

  def initialize(parameter)
    super
    @reason = "Method not allowed: #{parameter}"
  end
end
