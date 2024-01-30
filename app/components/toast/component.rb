# frozen_string_literal: true

class Toast::Component < ViewComponent::Base
  include ActiveModel::Validations

  attr_reader :toast_type

  validates :toast_type, presence: true

  def before_render
    validate!
  end

  def initialize(toast_type:)
    @toast_type = toast_type
    super
  end
end
