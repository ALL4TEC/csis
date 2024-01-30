# frozen_string_literal: true

module EnumSelect
  extend ActiveSupport::Concern

  included do |base|
    @clazz = base.is_a?(Class) ? base.to_s : base.class_name

    # Create a method #{pluralized_attr}_select for each enum
    # which can slice values if passing an array of symbols as argument
    # Following is the new prototype of enums method:
    # enum(name = nil, values = nil, **options)
    # **@params name: ** Name of the enum
    # **@params values: ** Values of the enum
    # **@params opts: ** Options of the enum
    def self.enum_with_select(name, values, **)
      define_selects(name, values)
      enum(name, values, **)
    end

    def self.define_selects(name, value)
      pluralized_attr = name.to_s.pluralize
      singleton_class.send(:define_method, "#{pluralized_attr}_select") do |*args|
        define_select(name, value, *args)
      end
    end

    # **@params name: ** Name of a definition
    # **@params value: ** Value of a definition
    # **@returns : an array containing [human translation of enum, enum key]**
    def self.define_select(name, value, *args)
      @clazz ||= to_s
      human = ->(k, _v) { [instance_eval(@clazz).human_attribute_name("#{name}.#{k}"), k] }
      values = args.present? ? value.slice(*args[0]) : value
      values.map(&human)
    end
  end
end
