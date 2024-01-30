# frozen_string_literal: true

class CyberwatchConfig < Account
  include ApiAuthAccount
  include ScannerConfigScheduler

  validates :url, presence: true

  validate :vm_import_cron_presence, on: :create

  after_create do
    # Update crons polymorphic target id
    tmp_vm_import_cron.update!(cronable_id: id)
    schedule_imports
  end

  after_update do
    handle_imports_schedules
  end

  after_discard do
    remove_scheduled_imports
  end

  # Undiscard ses rapports après avoir été undiscardé
  after_undiscard do
    schedule_imports
  end

  def to_s
    name
  end

  def any_scan?
    vm_scans.present?
  end
end
