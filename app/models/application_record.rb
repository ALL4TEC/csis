# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  BLANK = [nil, ''].freeze
  scope :in, ->(ids) { where(id: ids) }
end
