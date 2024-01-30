# frozen_string_literal: true

class QualysConfig < Account
  include BasicAccount
  include ScannerConfigScheduler

  has_one :ext,
    class_name: 'QualysConfigExt',
    inverse_of: :qualys_config,
    dependent: :destroy,
    autosave: true

  delegate :kind, :kind=, to: :lazily_built_ext

  has_many :qualys_vm_clients,
    class_name: 'QualysVmClient',
    primary_key: :id,
    inverse_of: :qualys_config,
    dependent: :destroy

  has_many :qualys_wa_clients,
    class_name: 'QualysWaClient',
    primary_key: :id,
    inverse_of: :qualys_config,
    dependent: :destroy

  scope :consultants, -> { QualysConfigExt.consultants_kind.where(qualys_config: :kept) }

  validates :url, presence: true
  validates :kind, presence: true

  validate :import_crons_presence, on: :create

  after_create do
    # Update crons polymorphic target id
    tmp_vm_import_cron.update!(cronable_id: id)
    tmp_wa_import_cron.update!(cronable_id: id)
    schedule_imports
  end

  after_update do
    handle_imports_schedules
  end

  after_discard do
    remove_scheduled_imports
  end

  # Reschedule les imports
  after_undiscard do
    schedule_imports
  end

  def to_s
    name
  end

  def any_scan?
    wa_scans.present? || vm_scans.present?
  end

  class << self
    # Ransack
    def ransackable_attributes(_auth_object = nil)
      %w[created_at creator_id discarded_at external_application_id id name type updated_at url
         verify_ssl_certificate]
    end

    def kept_consultants
      QualysConfigExt.consultants_kind.flat_map(&:qualys_config).select do |qc|
        qc.discarded_at.nil?
      end
    end
  end

  private

  def lazily_built_ext
    ext || build_ext
  end
end
