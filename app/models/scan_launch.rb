# frozen_string_literal: true

# Entity allowing to store data specified to launch a scan
# such as options, target, etc...
# and to store its result in a file
# for future treatment: import or simple display
class ScanLaunch < ApplicationRecord
  include EnumSelect
  has_paper_trail

  # Has to be called before has_one_attached (https://github.com/rails/rails/issues/36994)
  after_update_commit do
    # If status == done -> trigger scan_import if scanner in importable scanners
    if done?
      if scan_configuration.auto_import? &&
         scanner.to_sym.in?(ScanConfiguration::IMPORTABLE_SCANNERS)
        ReportScanLaunchService.launch_import(self, launcher)
      end
      notify_team_members
    end
  end

  before_destroy do
    NotificationService.clear_related_to(self)
  end

  has_one_attached :result

  enum_with_select :status, { created: 0, launched: 1, done: 2, errored: 3 }

  belongs_to :job,
    class_name: 'Job',
    inverse_of: :scan_launch,
    primary_key: :id,
    foreign_key: :csis_job_id,
    optional: true

  belongs_to :scan_configuration,
    class_name: 'ScanConfiguration',
    inverse_of: :scan_launches,
    primary_key: :id

  belongs_to :report,
    class_name: 'Report',
    inverse_of: :scan_launches,
    primary_key: :id,
    optional: true

  has_one :scan_import,
    class_name: 'ScanImport',
    inverse_of: :scan_launch,
    dependent: :nullify,
    primary_key: :id
  has_one :report_scan_import, through: :scan_import

  accepts_nested_attributes_for :scan_configuration

  delegate :auto_import, to: :scan_configuration
  delegate :auto_aggregate, to: :scan_configuration
  delegate :auto_aggregate_mixing, to: :scan_configuration
  delegate :target, to: :scan_configuration
  delegate :scanner, to: :scan_configuration
  delegate :scan_type, to: :scan_configuration
  delegate :scan_name, to: :scan_configuration
  delegate :launcher, to: :scan_configuration
  delegate :parameters, to: :scan_configuration
  delegate :to_s, to: :scan_configuration

  def to_s
    "#{scan_configuration} | #{status}"
  end

  private

  def notify_team_members
    receivers = if report.present?
                  report&.project&.staffs
                else
                  [launcher]
                end
    BroadcastService.notify(receivers, :scan_launch_done, versions.last)
  end
end
