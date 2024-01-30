# frozen_string_literal: true

module RansackHelper
  def sort_link_unless(condition, search_object, attribute, *, &block)
    if condition
      yield(block) if block
    else
      sort_link(search_object, attribute, *, &block)
    end
  end

  def sort_link_if(condition, search_object, attribute, *, &block)
    if condition
      sort_link(search_object, attribute, *, &block)
    elsif block
      yield(block)
    end
  end
end
