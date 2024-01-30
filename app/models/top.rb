# frozen_string_literal: true

class Top < ApplicationRecord
  has_paper_trail

  has_many :references,
    class_name: 'Reference',
    inverse_of: :top,
    primary_key: :id,
    dependent: :delete_all

  has_many :report_tops,
    class_name: 'ReportTop',
    inverse_of: :top,
    primary_key: :id,
    dependent: :delete_all

  has_many :reports, through: :report_tops

  validates :name, presence: true

  def to_s
    name
  end
end
