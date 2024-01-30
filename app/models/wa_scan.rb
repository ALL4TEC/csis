# frozen_string_literal: true

# = WaScan
#
# Le modèle +WaScan+ représente un scan (ou tir) lancé par un ingénieur SOC
# Dans le cas des Web Applications (WA) :
#
# Le +WaScan+ est lié à plusieurs reports
# Le +WaScan+ est lié à plusieurs +WaTarget+ (les destinations du scan)
# Un +WaScan+ contient nécessairement un +internal_id+(id du scanner), un nom(name), une référence,
# un type, un statut et une date de lancement.
class WaScan < Scan
  include KindConcern

  has_one_attached :landing_page do |attachable|
    attachable.variant :thumb, resize_to_limit: [80, 60]
  end

  attribute :crawl_duration, :string
  attribute :test_duration, :string

  has_paper_trail

  # Needs to be after has_paper_trail
  after_create do
    notify_team_members(:scan_created)
    # Le jour où l'on utilisera +sieurs workers, il faudra delay le job pour s'assurer de son
    # exécution après la fin de l'import de ses occurrences
    VerifyAutoGenerationJob.perform_later(self)
  end

  before_destroy do
    NotificationService.clear_related_to(self)
    notify_team_members
  end

  has_many :report_wa_scans,
    class_name: 'ReportWaScan',
    inverse_of: :wa_scan,
    dependent: :delete_all

  has_many :reports,
    class_name: 'Report',
    foreign_key: :report_id,
    inverse_of: :wa_scans,
    through: :report_wa_scans

  has_many :occurrences,
    class_name: 'WaOccurrence',
    inverse_of: :scan,
    foreign_key: :scan_id,
    primary_key: :id,
    dependent: :destroy

  belongs_to :account,
    class_name: 'Account',
    primary_key: :id,
    inverse_of: :wa_scans,
    optional: true

  belongs_to :qualys_wa_client,
    class_name: 'QualysWaClient',
    primary_key: :id,
    inverse_of: :wa_scans,
    optional: true

  belongs_to :scan_import,
    class_name: 'ScanImport',
    primary_key: :id,
    foreign_key: :import_id,
    inverse_of: :wa_scans,
    optional: true

  validates :internal_id, presence: true, if: -> { account.present? }
  validates :name, presence: true
  validates :status, presence: true

  # TODO: Trouver une autre option s'il s'avère qu'un WaScan puisse avoir plusieurs targets
  def url
    targets.first&.url
  end

  def web_app_name
    targets.first&.name
  end

  def to_s
    name
  end
end
