# frozen_string_literal: true

module ClearedAttrEncryptedConcern
  extend ActiveSupport::Concern

  included do |_base|
    @cleared_encrypted_attributes = []

    before_update :clear_encrypted_attr_changes

    def clear_encrypted_attr_changes
      # Call clear_encrypted_#{attr}_changes for all cleared_attr_encrypted
      self.class.cleared_encrypted_attributes.each do |attr|
        send(:"clear_encrypted_#{attr}_changes")
      end
    end
  end

  class_methods do
    # Override attr_encrypted to add
    # a method clear_encrypted_#{attr}_changes for each attr_encrypted
    def cleared_attr_encrypted(*attrs)
      attr_encrypted(*attrs)
      attr = attrs.first
      @cleared_encrypted_attributes << attr
      define_method(:"clear_encrypted_#{attr}_changes") do
        return if send(:"encrypted_#{attr}").present?

        clear_attribute_changes(["encrypted_#{attr}", "encrypted_#{attr}_iv"])
      end
      validates(attr, presence: true, on: :create)
    end

    def cleared_attr_encrypted_no_validation(*attrs)
      attr_encrypted(*attrs)
      attr = attrs.first
      @cleared_encrypted_attributes << attr
      define_method(:"clear_encrypted_#{attr}_changes") do
        return if send(:"encrypted_#{attr}").present?

        clear_attribute_changes(["encrypted_#{attr}", "encrypted_#{attr}_iv"])
      end
    end

    def cleared_encrypted_attributes
      @cleared_encrypted_attributes ||= []
    end
  end
end
