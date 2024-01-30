# frozen_string_literal: true

class ReportImport < ApplicationRecord
  has_paper_trail

  has_one_attached :document

  belongs_to :report,
    inverse_of: :report_imports

  validates :document, presence: true
end
