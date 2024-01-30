# frozen_string_literal: true

class Reference < ApplicationRecord
  has_paper_trail

  default_scope { order(:rank) }

  belongs_to :top,
    class_name: 'Top',
    primary_key: :id,
    inverse_of: :references

  has_many :aggregate_references,
    class_name: 'AggregateReference',
    inverse_of: :reference,
    primary_key: :id,
    dependent: :delete_all

  has_many :aggregates, through: :aggregate_references

  validates :rank, presence: true
  validates :name, presence: true
  # Les couples (rank, top_id) && (name, top_id) doivent être uniques
  validates :rank, :name, uniqueness: { scope: :top_id }

  def to_s
    name
  end
end
