# frozen_string_literal: true

class Note < ApplicationRecord
  include DiscardWithPaperTrailEvents::Model

  # title, author
  has_rich_text :content

  belongs_to :report,
    class_name: 'Report',
    inverse_of: :notes,
    primary_key: :id

  belongs_to :author,
    class_name: 'User',
    inverse_of: :staff_notes,
    foreign_key: :staff_id,
    primary_key: :id

  validates :title, presence: true

  # Ransack
  class << self
    def ransackable_attributes(_auth_object = nil)
      %w[created_at discarded_at id report_id staff_id title updated_at]
    end

    def ransackable_associations(_auth_object = nil)
      %w[author report rich_text_content versions]
    end
  end

  def to_s
    "#{title} (#{author})"
  end
end
