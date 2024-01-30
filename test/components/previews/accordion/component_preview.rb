# frozen_string_literal: true

class Accordion::ComponentPreview < ViewComponent::Preview
  def default
    render(Accordion::Component.new)
  end
end
