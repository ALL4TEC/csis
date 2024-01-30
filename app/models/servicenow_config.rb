# frozen_string_literal: true

class ServicenowConfig < Account
  include TicketingAccount
  include ClearedAttrEncryptedConcern

  has_one :ext,
    class_name: 'ServicenowConfigExt',
    inverse_of: :servicenow_config,
    dependent: :destroy,
    autosave: true

  delegate :status, :status=, to: :lazily_built_ext
  delegate :need_refresh_at, :need_refresh_at=, to: :lazily_built_ext
  delegate :fixed_vuln, :fixed_vuln=, to: :lazily_built_ext
  delegate :accepted_risk, :accepted_risk=, to: :lazily_built_ext

  cleared_attr_encrypted_no_validation :login, key: Rails.application.credentials.key
  cleared_attr_encrypted_no_validation :password, key: Rails.application.credentials.key
  cleared_attr_encrypted :api_key, key: Rails.application.credentials.key
  cleared_attr_encrypted :secret_key, key: Rails.application.credentials.key

  validates :url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp }
  validates :status, presence: true
  validates :fixed_vuln, presence: true
  validates :accepted_risk, presence: true

  def any_action?
    actions.present?
  end

  def remote_issue_url_prefix
    "#{url}/nav_to.do?uri=incident.do?sys_id="
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[accounts_suppliers accounts_teams accounts_users actions assets assets_imports creator crons
       ext external_application issues scans_imports suppliers teams users versions vm_scans
       vulnerabilities_imports wa_scans]
  end

  def supports_resolution_code?
    true
  end

  private

  def lazily_built_ext
    ext || build_ext
  end
end
