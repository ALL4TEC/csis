# frozen_string_literal: true

class Accordion::Component < ViewComponent::Base
  include ActiveModel::Validations

  renders_many :accordion_items, Accordion::Item::Component

  attr_reader :accordion_id

  validates :accordion_id, presence: true

  def before_render
    validate!
  end

  def initialize(id:)
    @accordion_id = id
    super
  end
end
