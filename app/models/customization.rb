# frozen_string_literal: true

class Customization < ApplicationRecord
  validates :key, presence: true
  validates :value, presence: true # Validates hex color for now

  # Class method, return value when found, nil otherwise
  def self.get_value(key)
    color = find_by(key: key)
    color.value.delete('#') if color.present?
  end

  def to_s
    value
  end
end
