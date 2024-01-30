# frozen_string_literal: true

class ExternalApplication < ApplicationRecord
  include DiscardWithPaperTrailEvents::Model
  include ClearedAttrEncryptedConcern

  cleared_attr_encrypted :client_id, key: Rails.application.credentials.key
  cleared_attr_encrypted :client_secret, key: Rails.application.credentials.key
  cleared_attr_encrypted :signing_secret, key: Rails.application.credentials.key

  validates :name, presence: true
  validates :app_id, presence: true, on: :create
  # type does not need validation as it has default value

  has_many :accounts,
    class_name: 'Account',
    inverse_of: :external_application,
    primary_key: :id,
    dependent: :destroy

  def to_s
    "#{name}: #{app_id}"
  end
end
