# frozen_string_literal: true

class AggregateContent < ApplicationRecord
  has_one_attached :image do |attachable|
    attachable.variant :thumb, resize_to_limit: [80, 60]
  end

  belongs_to :aggregate,
    class_name: 'Aggregate',
    inverse_of: :contents,
    primary_key: :id

  default_scope { order(:rank) }
end
