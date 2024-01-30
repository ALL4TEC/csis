# frozen_string_literal: true

class IconedLabel::Component < ViewComponent::Base
  include ActiveModel::Validations

  attr_reader :icon, :label

  validates :icon, presence: true
  validates :label, presence: true

  def before_render
    validate!
  end

  # @param **icon:** {clazz:, name:}
  # @param **label:** {clazz: , value:}
  def initialize(icon:, label:)
    @icon = default_icon.merge!(icon)
    @label = default_label.merge!(label)
    super
  end

  private

  def empty_clazz
    { clazz: '' }
  end

  def default_icon
    empty_clazz
  end

  def default_label
    empty_clazz
  end
end
