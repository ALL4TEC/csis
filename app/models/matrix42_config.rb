# frozen_string_literal: true

class Matrix42Config < Account
  include TicketingAccount
  include ClearedAttrEncryptedConcern

  has_one :ext,
    class_name: 'Matrix42ConfigExt',
    inverse_of: :matrix42_config,
    dependent: :destroy,
    autosave: true

  delegate :status, :status=, to: :lazily_built_ext
  delegate :default_ticket_type, :default_ticket_type=, to: :lazily_built_ext
  delegate :need_refresh_at, :need_refresh_at=, to: :lazily_built_ext
  delegate :api_url, :api_url=, to: :lazily_built_ext

  cleared_attr_encrypted :api_key, key: Rails.application.credentials.key
  cleared_attr_encrypted_no_validation :secret_key, key: Rails.application.credentials.key

  validates :url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp }
  validates :api_url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp }
  validates :status, presence: true
  validates :default_ticket_type, presence: true

  def any_action?
    actions.present?
  end

  def remote_issue_url_prefix
    # without the chomp, there may be two '/' and Matrix42 will 404 when trying to download JS
    "#{url.chomp('/')}/wm/app-ServiceDesk/global-search/"
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
