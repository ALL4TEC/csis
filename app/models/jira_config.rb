# frozen_string_literal: true

# Data in DB:
# - config name -> Account.name (accounts table)
# - Jira base URL (i.e. https://intranet.company.com/) -> Account.url (accounts table)
# - Jira context (i.e. /ticketing) -> JiraConfigExt.context (jira_configs table)
# - Jira project ID -> JiraConfigExt.project_id (jira_configs table)
# - request/auth token -> BasicAccount.login (accounts table)
# - request/auth secret -> BasicAccount.password (accounts table)
# - status -> JiraConfigExt.status (jira_configs table)
# - expiration date -> JiraConfigExt.expiration_date (jira_configs table)
#   > request token is valid for 10 minutes, auth token for 5 years

class JiraConfig < Account
  include BasicAccount
  include ValidAttribute
  include TicketingAccount

  has_one :ext,
    class_name: 'JiraConfigExt',
    inverse_of: :jira_config,
    dependent: :destroy,
    autosave: true

  delegate :context, :context=, to: :lazily_built_ext
  delegate :project_id, :project_id=, to: :lazily_built_ext
  delegate :status, :status=, to: :lazily_built_ext
  delegate :expiration_date, :expiration_date=, to: :lazily_built_ext

  validates :url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp }
  validates :project_id, presence: true
  validates :status, presence: true
  validates :expiration_date, presence: true
  validates :context, allow_blank: true, format: { with: %r{\A/[a-zA-Z0-9]+\z} }

  # TODO: soft-delete pour les issues qui l'utilisent (sinon on devrait tout virer)
  # TODO: ne pas permettre la modification quand y'a des issues associées
  # (mais permettre le refresh)

  def any_action?
    actions.present?
  end

  def remote_issue_url_prefix
    if context.empty?
      "#{url}/browse/"
    else
      "#{url}#{context}/browse/"
    end
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[accounts_suppliers accounts_teams accounts_users actions assets assets_imports creator
       crons ext external_application issues scans_imports suppliers teams users versions vm_scans
       vulnerabilities_imports wa_scans]
  end

  private

  def lazily_built_ext
    ext || build_ext
  end
end
