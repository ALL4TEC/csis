# frozen_string_literal: true

class Account < ApplicationRecord
  include DiscardWithPaperTrailEvents::Model

  validates :name, presence: true

  belongs_to :creator,
    class_name: 'User',
    inverse_of: :created_accounts,
    primary_key: :id,
    optional: true

  belongs_to :external_application,
    class_name: 'ExternalApplication',
    inverse_of: :accounts,
    primary_key: :id,
    optional: true

  has_many :accounts_teams,
    class_name: 'AccountTeam',
    primary_key: :id,
    inverse_of: :account,
    dependent: :delete_all

  has_many :teams, through: :accounts_teams

  has_many :accounts_suppliers,
    class_name: 'AccountSupplier',
    inverse_of: :account,
    dependent: :delete_all

  has_many :suppliers,
    class_name: 'Client',
    foreign_key: :supplier_id,
    inverse_of: :accounts,
    through: :accounts_suppliers

  has_many :accounts_users,
    class_name: 'AccountUser',
    primary_key: :id,
    inverse_of: :account,
    dependent: :delete_all

  has_many :users, through: :accounts_users

  has_many :vm_scans,
    class_name: 'VmScan',
    inverse_of: :account,
    primary_key: :id,
    dependent: :nullify

  has_many :wa_scans,
    class_name: 'WaScan',
    inverse_of: :account,
    primary_key: :id,
    dependent: :nullify

  has_many :vulnerabilities_imports,
    class_name: 'VulnerabilityImport',
    inverse_of: :account,
    primary_key: :id,
    dependent: :nullify

  has_many :scans_imports,
    class_name: 'ScanImport',
    inverse_of: :account,
    primary_key: :id,
    dependent: :nullify

  has_many :crons,
    class_name: 'Cron',
    dependent: :delete_all,
    as: :cronable

  has_many :assets,
    class_name: 'Asset',
    inverse_of: :account,
    primary_key: :id,
    dependent: :nullify

  has_many :assets_imports,
    class_name: 'AssetImport',
    inverse_of: :account,
    primary_key: :id,
    dependent: :nullify

  # VULNERABILITIES SCANNERS
  scope :qualys_configs, -> { where(type: 'QualysConfig') }
  scope :ias_configs, -> { where(type: 'InsightAppSecConfig') }
  scope :cyberwatch_configs, -> { where(type: 'CyberwatchConfig') }

  # CHATS
  scope :slack_configs, -> { where(type: 'SlackConfig') }
  scope :google_chat_configs, -> { where(type: 'GoogleChatConfig') }
  scope :microsoft_teams_configs, -> { where(type: 'MicrosoftTeamsConfig') }
  scope :zoho_cliq_configs, -> { where(type: 'ZohoCliqConfig') }

  # TICKETING
  scope :jira_configs, -> { where(type: 'JiraConfig') }
  scope :servicenow_configs, -> { where(type: 'ServicenowConfig') }
  scope :matrix42_configs, -> { where(type: 'Matrix42Config') }

  scope :active, -> { kept }
  scope :inactive, -> { trashed }

  def to_s
    name
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[created_at creator_id discarded_at external_application_id id name type updated_at url
       verify_ssl_certificate]
  end

  def supports_resolution_code?
    false
  end
end
