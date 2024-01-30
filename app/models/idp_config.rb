# frozen_string_literal: true

class IdpConfig < ApplicationRecord
  include DiscardWithPaperTrailEvents::Model

  before_discard do
    deactivate
  end

  has_one_attached :idp_metadata_xml

  validates :name, presence: true, uniqueness: true
  validates :active, inclusion: { in: [true, false] }
  validate :metadata_url_or_file
  attr_accessor :idp_entity_id

  scope :active, -> { where(active: true) }

  def self.ransackable_attributes(_auth_object = nil)
    %w[active created_at discarded_at id idp_entity_id idp_metadata_url name updated_at]
  end

  def activate
    self.active = true
    save
  end

  def deactivate
    self.active = false
    save
  end

  def certificate
    Rails.application.config.saml_sp_certificate
  end

  def private_key
    Rails.application.config.saml_sp_private_key
  end

  def to_s
    name
  end

  private

  def metadata_url_or_file
    return unless idp_metadata_xml.blank? && idp_metadata_url.blank?

    errors.add(:idp_metadata_url, I18n.t('idp_configs.notices.no_metadata'))
    errors.add(:idp_metadata_xml, I18n.t('idp_configs.notices.no_metadata'))
  end
end
