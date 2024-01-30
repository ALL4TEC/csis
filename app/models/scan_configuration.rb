# frozen_string_literal: true

# Store scan configurations
class ScanConfiguration < ApplicationRecord
  include EnumSelect
  has_paper_trail

  SCANNERS_DATA = {
    zaproxy: {
      scan_types: {
        Passive: 'zap-baseline-scan',
        Full: 'zap-full-scan',
        Api: 'zap-api-scan'
      },
      options: {
        '-a': 'Include the alpha passive scan rules as well',
        '-j': 'Use the Ajax spider in addition to the traditional one',
        '-f openapi': 'Scan an openapi',
        '-f soap': 'Scan a soap api'
      }
    }
  }.freeze

  has_many :scan_launches,
    class_name: 'ScanLaunch',
    inverse_of: :scan_configuration,
    primary_key: :id,
    dependent: :nullify

  has_one :scheduled_scan,
    class_name: 'ScheduledScan',
    inverse_of: :scan_configuration,
    primary_key: :id,
    dependent: :destroy

  belongs_to :launcher,
    class_name: 'User',
    inverse_of: :created_scan_configurations

  before_validation :default_scan_name, on: :create

  IMPORTABLE_SCANNERS = %i[zaproxy].freeze

  validates :scanner, presence: true
  validates :scan_type, presence: true
  validates :scan_name, presence: true
  validates :target, presence: true
  # rubocop:disable Lint/LiteralAsCondition
  validates_with ZaproxyTargetValidator if :zaproxy_scanner?
  # rubocop:enable Lint/LiteralAsCondition
  validates :auto_import, inclusion: { in: [true, false] }
  validates :auto_aggregate, inclusion: { in: [true, false] }
  validates :auto_aggregate_mixing, inclusion: { in: [true, false] }

  enum_with_select :scanner, { zaproxy: 0 }, suffix: true

  # used to store cron created before project id is available...
  attr_accessor :tmp_scan_launch_cron

  def target=(value)
    super(value.strip)
  end

  def to_s
    "#{scanner}: #{scan_type} on #{target} with #{parameters} by #{launcher}"
  end

  def default_scan_name
    self.scan_name = "#{scanner}: #{target}" if scan_name.blank?
  end
end
