# frozen_string_literal: true

# = Report
#
# Le modèle Report correspond à un rapport de scans, ce rapport détaille les différentes
# vulnérabilités détectées.
#
# Un Report est lié à un Staff, ingénieur SOC reponsable de ce rapport
# Un Report est lié à un Project
# Un Report est lié à un VmScan et à un WaScan.

COEFFS = {
  critical: {
    vulnerability: { system: 10, applicative: 10 },
    potential_vulnerability: { system: 5, applicative: 5 },
    vulnerability_or_potential_vulnerability: { system: 5, applicative: 2.5 },
    information_gathered: { system: 2.5, applicative: 0 }
  },
  high: {
    vulnerability: { system: 8, applicative: 8 },
    potential_vulnerability: { system: 4, applicative: 4 },
    vulnerability_or_potential_vulnerability: { system: 4, applicative: 2 },
    information_gathered: { system: 2, applicative: 0 }
  },
  medium: {
    vulnerability: { system: 6, applicative: 6 },
    potential_vulnerability: { system: 3, applicative: 3 },
    vulnerability_or_potential_vulnerability: { system: 3, applicative: 1.5 },
    information_gathered: { system: 1.5, applicative: 0 }
  },
  low: {
    vulnerability: { system: 4, applicative: 4 },
    potential_vulnerability: { system: 2, applicative: 2 },
    vulnerability_or_potential_vulnerability: { system: 2, applicative: 1 },
    information_gathered: { system: 1, applicative: 0 }
  },
  trivial: {
    vulnerability: { system: 0, applicative: 0 },
    potential_vulnerability: { system: 0, applicative: 0 },
    vulnerability_or_potential_vulnerability: { system: 0, applicative: 0 },
    information_gathered: { system: 0, applicative: 0 }
  },
  falsepositive: {
    vulnerability: { system: 0, applicative: 0 },
    potential_vulnerability: { system: 0, applicative: 0 },
    vulnerability_or_potential_vulnerability: { system: 0, applicative: 0 },
    information_gathered: { system: 0, applicative: 0 }
  }
}.freeze

class Report < ApplicationRecord
  include DiscardWithPaperTrailEvents::Model
  include EnumSelect

  VULN_CLAZZS = %w[ScanReport PentestReport].freeze
  OTHER_CLAZZS = %w[ActionPlanReport].freeze
  ALL_CLAZZS = VULN_CLAZZS + OTHER_CLAZZS

  # after_initialize :init

  after_commit do
    unless discarded?
      project.statistics.update_stats
      project.certificate.update_certificate
    end
  end

  # Discard ses agrégats avant d'être discardé
  before_discard do
    false unless aggregates.discard_all
  end

  # Undiscard ses agrégats après avoir été undiscardé
  after_undiscard do
    false unless aggregates.trashed.undiscard_all
  end

  serialize :aggregates_order_by, Array

  default_scope -> { kept }

  # Ransack
  class << self
    def ransackable_attributes(_auth_object = nil)
      %w[addendum aggregates_order_by base_report_id created_at discarded_at edited_at id
         introduction language_id level org_introduction project_id purpose scoring_vm
         scoring_vm_aggregate scoring_wa scoring_wa_aggregate signatory_id staff_id subtitle title
         type updated_at]
    end

    def ransackable_associations(_auth_object = nil)
      %w[action_imports actions aggregates client_logo_attachment client_logo_blob contacts
         exports language notes project report_action_imports report_contacts report_imports
         report_scan_imports report_targets report_tops report_vm_scans report_wa_scans
         scan_imports scan_launches signatory staff targets tops versions vm_occurrences vm_scans
         vm_vulns wa_occurrences wa_scans wa_vulns]
    end
  end

  has_one_attached :client_logo do |attachable|
    attachable.variant :thumb, resize_to_limit: [80, 60]
  end

  belongs_to :staff,
    class_name: 'User',
    primary_key: :id,
    inverse_of: :created_reports

  belongs_to :signatory,
    class_name: 'User',
    primary_key: :id,
    inverse_of: :signed_reports,
    optional: true

  # @returns all staffs in common between members of project.teams and current_user.staff_teams
  # common teams between current_user and project => Project::TeamPolicy
  def potential_signatories(current_user)
    UserDecorator.decorate_collection(
      Project::TeamPolicy::Scope.new(current_user, project, Team).resolve.flat_map(&:staffs)
    ).map { |decorated_user| [decorated_user.full_name_and_email, decorated_user.object.id] }
                 .uniq
  end

  has_many :report_tops,
    class_name: 'ReportTop',
    inverse_of: :report,
    primary_key: :id,
    dependent: :delete_all

  has_many :tops, through: :report_tops

  has_many :aggregates,
    class_name: 'Aggregate',
    inverse_of: :report,
    primary_key: :id,
    dependent: :destroy
  # has_many :aggregates_actions, through: :aggregates
  # has_many :actions, through: :aggregates_actions
  has_many :actions, through: :aggregates

  belongs_to :project,
    class_name: 'Project',
    primary_key: :id,
    inverse_of: :reports

  has_many :report_vm_scans,
    class_name: 'ReportVmScan',
    inverse_of: :report,
    dependent: :delete_all

  has_many :report_targets, through: :report_vm_scans
  has_many :targets, through: :report_targets

  has_many :vm_scans,
    class_name: 'VmScan',
    foreign_key: :vm_scan_id,
    inverse_of: :reports,
    through: :report_vm_scans

  has_many :vm_occurrences, through: :vm_scans, source: :occurrences
  has_many :vm_vulns, -> { where.not(kind: :information_gathered) },
    through: :vm_occurrences, source: :vulnerability

  has_many :report_wa_scans,
    class_name: 'ReportWaScan',
    inverse_of: :report,
    dependent: :delete_all

  has_many :wa_scans,
    class_name: 'WaScan',
    foreign_key: :wa_scan_id,
    inverse_of: :reports,
    through: :report_wa_scans

  has_many :wa_occurrences, through: :wa_scans, source: :occurrences
  has_many :wa_vulns, -> { where.not(kind: :information_gathered) },
    through: :wa_occurrences, source: :vulnerability

  has_many :exports,
    class_name: 'ReportExport',
    inverse_of: :report,
    dependent: :destroy

  has_many :report_imports,
    class_name: 'ReportImport',
    inverse_of: :report,
    primary_key: :id,
    dependent: :destroy

  # SCANS
  has_many :report_scan_imports,
    class_name: 'ReportScanImport',
    inverse_of: :report,
    primary_key: :id,
    dependent: :destroy
  has_many :scan_imports, through: :report_scan_imports

  # ACTIONS
  has_many :report_action_imports,
    class_name: 'ReportActionImport',
    inverse_of: :report,
    primary_key: :id,
    dependent: :destroy
  has_many :action_imports, through: :report_action_imports

  has_many :scan_launches,
    class_name: 'ScanLaunch',
    inverse_of: :report,
    primary_key: :id,
    dependent: :destroy

  belongs_to :language,
    class_name: 'Language',
    inverse_of: :reports,
    primary_key: :id,
    optional: true

  has_many :report_contacts,
    class_name: 'ReportContact',
    inverse_of: :report,
    dependent: :delete_all

  has_many :contacts,
    -> { ordered_alphabetically },
    through: :report_contacts,
    source: :contact

  has_many :notes,
    class_name: 'Note',
    inverse_of: :report,
    primary_key: :id,
    dependent: :destroy

  REPORTS_NOTICES_CONTACTS_LENGTH = 'reports.notices.contacts_length'

  validates :title, presence: true
  validates :edited_at, presence: true, uniqueness: {
    scope: %i[project_id discarded_at], conditions: -> { where(discarded_at: nil) },
    message: I18n.t('activerecord.errors.models.report.attributes.edited_at.already_used')
  }
  validates :contacts, length: { in: 1..5, message: I18n.t(REPORTS_NOTICES_CONTACTS_LENGTH) }

  enum_with_select :level, { in_progress: 0, satisfactory: 1, good: 2, very_good: 3, excellent: 4 }

  scope :of_action_plan_type, -> { where(type: 'ActionPlanReport') }
  scope :of_scan_type, -> { where(type: 'ScanReport') }
  scope :of_pentest_type, -> { where(type: 'PentestReport') }

  def to_s
    title
  end

  # Regenerates report scoring
  def regenerate_scoring
    self.scoring_vm = scoring(:system, :scan)
    self.scoring_wa = scoring(:applicative, :scan)
    self.level = 4 - severity
    save
  end

  # Return an int corresponding to the most important severity among
  # not falsepositive aggregates vm_occurrences and wa_occurrences
  def severity
    aggs = aggregates.not_false_positive
                     .includes(wa_occurrences: :vulnerability, vm_occurrences: :vulnerability)

    return 0 if aggs.blank?

    %i[vm_occurrences wa_occurrences].map do |occurrences|
      aggs.flat_map(&occurrences).map { |x| x.vulnerability.severity_before_type_cast }.max
    end.compact_blank.max || 0
  end

  # Sums vulnerabilities scores of aggregate_kind
  # vuln score = COEFFS[severity][kind][aggregate_kind]
  # @param **aggregate_kind:** in Aggregate.kinds
  # @param **follow_type:** in Aggregate.follow_types
  # @param **opts:**
  def scoring(aggregate_kind, follow_type, opts = {})
    raise InvalidSourceError, aggregate_kind unless aggregate_kind.in?(Aggregate.kinds)
    raise InvalidSourceError, follow_type unless follow_type.in?(follow_types)

    if follow_type == :scan
      vulns = vulnerabilities(aggregate_kind, opts.slice(:severity))
      scores = vulns.map do |vulnerability|
        COEFFS[vulnerability.severity.to_sym][vulnerability.kind.to_sym][aggregate_kind] || 0
      end
    elsif follow_type == :pentest
      scores = aggregates.where(kind: aggregate_kind).map do |aggregate|
        COEFFS[aggregate.severity.to_sym][aggregate.status.to_sym][aggregate_kind] || 0
      end
    end
    scores.sum
  end

  # Return the vulnerabilities associated to this report via the given source.
  #
  # `aggregate_kind`: Either `:system` or `:applicative`
  # `opts`:
  #   `:kind`: Only return vulnerability with the given kind
  #   `:severity`: Only return vulnerability with the given severity
  def vulnerabilities(aggregate_kind, opts = {})
    raise InvalidSourceError, aggregate_kind unless aggregate_kind.in?(Aggregate.kinds)

    occurrences = scorable_occurrences(aggregate_kind)
    vulns = occurrences.map(&:vulnerability)
    vulns = Vulnerability.filter_opts(vulns, opts, :kind) if opts.key?(:kind)
    vulns = Vulnerability.filter_opts(vulns, opts, :severity) if opts.key?(:severity)
    vulns
  end

  def unaggregated_was
    unaggregated('wa')
  end

  def unaggregated_vms
    unaggregated('vm')
  end

  def follow_types
    %i[scan pentest action_plan]
  end

  def self.follow_types_select
    collection = [['ScanReport', I18n.t(REPORTS_NOTICES_CONTACTS_LENGTH)]]
    return unless Rails.application.config.pentest_enabled

    collection << ['PentestReport', I18n.t(REPORTS_NOTICES_CONTACTS_LENGTH)]
  end

  # List QIDs
  def raw_vulnerabilities
    wa_vulns + vm_vulns
  end

  # Count vulnerability occurrences
  def vulnerability_count(vuln)
    wa_vulns.where(id: vuln.id).count + vm_vulns.where(id: vuln.id).count
  end

  def self.exportable_columns
    %w[title project level edited_at scoring_vm scoring_wa]
  end

  def org_aggregates
    aggregates.organizational_kind
  end

  def vm_aggregates
    aggregates.system_kind
  end

  def wa_aggregates
    aggregates.applicative_kind
  end

  # Check that report is an instance of any class among VULN_CLAZZS
  def vuln?
    Report::VULN_CLAZZS.any? { |clazz| instance_of?(clazz.constantize) }
  end

  # Check that report is an instance of any class among ALL_CLAZZS
  def instanciated?
    Report::ALL_CLAZZS.any? { |clazz| instance_of?(clazz.constantize) }
  end

  def diffusion_list
    contacts.kept.actif.decorate.map { |contact| [contact.full_name_and_email] }
  end

  private

  # Check if intersection of occurrence aggregates and current report aggregates
  # is blank
  def unaggregated?(occurrence)
    (occurrence.aggregates & aggregates).blank?
  end

  def aggregated_and_not_false_positive?(occurrence)
    ReportPredicate.aggregated?(self, occurrence) &&
      ReportPredicate.not_false_positive_aggregate?(self, occurrence)
  end

  def unaggregated(kind)
    filter_occurrences(kind, 'unaggregated?')
  end

  # Occurrences taken into account for scoring:
  # unaggregated && not_false_positive
  def scorable_occurrences(aggregate_kind)
    filter_occurrences(KindUtil.to_accro(aggregate_kind), 'aggregated_and_not_false_positive?')
  end

  # Filter occurrences
  def filter_occurrences(aggregate_kind, conditional_method)
    lambda = ->(o) { send(conditional_method, o) }
    incl = [:"aggregate_#{aggregate_kind}_occurrences", :aggregates]
    send(:"#{aggregate_kind}_occurrences").includes(incl).select(&lambda)
  end
end

class InvalidSourceError < StandardError
  attr_reader :reason

  def initialize(source)
    super
    @reason = 'Invalid scoring source given.' \
              "Expected either :system or :applicative, found :#{source}"
  end
end
