# frozen_string_literal: true

class SellsyConfig < ApplicationRecord
  include DiscardWithPaperTrailEvents::Model
  include ClearedAttrEncryptedConcern

  cleared_attr_encrypted :consumer_token, key: Rails.application.credentials.key
  cleared_attr_encrypted :user_token, key: Rails.application.credentials.key
  cleared_attr_encrypted :consumer_secret, key: Rails.application.credentials.key
  cleared_attr_encrypted :user_secret, key: Rails.application.credentials.key

  validates :name, presence: true

  # Ransack
  def self.ransackable_attributes(_auth_object = nil)
    %w[created_at id name updated_at]
  end

  def to_s
    name
  end
end
