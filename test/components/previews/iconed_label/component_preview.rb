# frozen_string_literal: true

class IconedLabel::ComponentPreview < ViewComponent::Preview
  def default
    render(IconedLabel::Component.new)
  end
end
