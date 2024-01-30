# frozen_string_literal: true

class Accordion::Item::Component < ViewComponent::Base
  include ActiveModel::Validations

  renders_one :accordion_header, 'Accordion::Item::HeaderComponent'
  renders_one :accordion_body, 'Accordion::Item::BodyComponent'

  attr_reader :parent

  validates :parent, presence: true

  def before_render
    validate!
  end

  def initialize(parent:)
    @parent = parent
    super
  end

  class Accordion::Item::HeaderComponent < ViewComponent::Base
    attr_reader :id, :clazz

    def initialize(id:, clazz: 'fw-bold fs-5 p-1 bg-white line-hover-primary')
      @id = id
      @clazz = clazz
      super
    end

    def call
      content
    end
  end

  class Accordion::Item::BodyComponent < ViewComponent::Base
    attr_reader :id, :clazz, :expanded

    def initialize(id:, clazz: 'bg-white', expanded: false)
      @id = id
      @clazz = clazz
      @expanded = expanded
      super
    end

    def call
      content
    end
  end
end
