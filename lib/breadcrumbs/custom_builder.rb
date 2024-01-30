# frozen_string_literal: true

class CustomBuilder < BreadcrumbsOnRails::Breadcrumbs::Builder
  def render
    @elements.map do |element|
      render_element(element)
    end.join(@options[:separator] || ' &raquo; ')
  end

  def render_element(element)
    content = @context.link_to(compute_name(element),
      compute_path(element),
      element.options)
    if (tag = @options[:tag]).present?
      @context.content_tag(tag, content)
    else
      ERB::Util.h(content)
    end
  end
end
