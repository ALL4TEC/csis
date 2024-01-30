# frozen_string_literal: true

# Store scan configurations
class ScheduledScan < ApplicationRecord
  include DiscardWithPaperTrailEvents::Model
  include EnumSelect
  include ScheduledScanScheduler

  after_create do
    # Update crons polymorphic target id
    tmp_scheduled_scan_cron.update!(cronable_id: id)
    schedule_scheduled_scan
  end

  after_update do
    handle_scheduled_scan_schedule
  end

  after_discard do
    remove_scheduled_scan_schedule
  end

  after_undiscard do
    schedule_scheduled_scan
  end

  belongs_to :project,
    class_name: 'Project',
    inverse_of: :scheduled_scans

  belongs_to :scan_configuration,
    class_name: 'ScanConfiguration',
    inverse_of: :scheduled_scan,
    primary_key: :id

  has_many :scan_launches, through: :scan_configuration

  accepts_nested_attributes_for :scan_configuration

  delegate :auto_import, to: :scan_configuration
  delegate :auto_aggregate, to: :scan_configuration
  delegate :auto_aggregate_mixing, to: :scan_configuration
  delegate :target, to: :scan_configuration
  delegate :scanner, to: :scan_configuration
  delegate :scan_type, to: :scan_configuration
  delegate :launcher, to: :scan_configuration
  delegate :parameters, to: :scan_configuration

  validates :report_action, presence: true

  enum_with_select :scanner, { zaproxy: 0 }, suffix: true
  enum_with_select :report_action, { new: 0, last: 1 }, suffix: true

  # used to store cron created before project id is available...
  attr_accessor :tmp_scheduled_scan_cron

  def to_s
    "#{scan_configuration}: #{scheduled_scan_cron.value}"
  end
end
