# frozen_string_literal: true

class OccurrenceInput < SimpleForm::Inputs::CollectionInput
  include ActionView::Helpers::SanitizeHelper

  def input(wrapper_options = nil)
    label_method, value_method = detect_collection_methods

    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)
    @builder.collection_check_boxes(
      attribute_name,
      collection,
      value_method,
      label_method,
      input_options,
      merged_input_options
    ) do |builder|
      template.render(partial: 'occurrences/occurrence_input', locals: { builder: builder })
    end
  end

  # rubocop: disable Naming/PredicateName
  # Checkbox components do not use the required html tag.
  # More info: https://github.com/plataformatec/simple_form/issues/340#issuecomment-2871956
  def has_required?
    false
  end
  # rubocop: enable Naming/PredicateName

  # Do not attempt to generate label[for] attributes by default, unless an
  # explicit html option is given. This avoids generating labels pointing to
  # non existent fields.
  def generate_label_for_attribute?
    false
  end
end
