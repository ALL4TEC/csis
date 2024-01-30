# frozen_string_literal: true

# copy-pasted from https://github.com/KevinBongart/valid_attribute
# converted to a concern since the gem doesn't seem to work with Rails >=6

module ValidAttribute
  extend ActiveSupport::Concern

  def valid_attribute?(*attributes)
    errors.clear

    attributes.flatten!
    attributes = attributes.first if attributes.first.is_a?(Hash)

    attributes.each do |attribute, validator_types|
      validators = self.class.validators_on(attribute)

      if validator_types.present?
        validator_types = Array(validator_types)
        validators.select! { |validator| validator.kind.in?(validator_types) }
      end

      validators.each { |validator| validator.validate(self) }
    end

    errors.empty?
  end
end
