# frozen_string_literal: true

class Accordion::Item::ComponentPreview < ViewComponent::Preview
  def default
    render(Accordion::Item::Component.new)
  end
end
