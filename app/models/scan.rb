# frozen_string_literal: true

# Imported scan common content
class Scan < ApplicationRecord
  include ScanLaunchedSinceSixMonths

  self.abstract_class = true

  has_many :target_scans,
    class_name: 'TargetScan',
    inverse_of: :scan,
    dependent: :delete_all

  has_many :targets,
    class_name: 'Target',
    foreign_key: :target_id,
    through: :target_scans

  attr_readonly :reference

  validates :reference, presence: true
  validates :scan_type, presence: true
  validates :launched_at, presence: true

  scope :qualys, -> { where(account: QualysConfig.all) }
  scope :ias, -> { where(account: InsightAppSecConfig.all) }

  def readers
    if account.present?
      account.teams.flat_map(&:staffs).uniq
    else
      scan_import&.report_scan_import&.report&.project&.staffs
    end
  end

  def notify_team_members(event = :scan_destroyed)
    BroadcastService.notify(readers, event, versions.last)
  end

  def in_one_report?
    reports.count.positive?
  end
end
