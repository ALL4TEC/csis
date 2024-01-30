# frozen_string_literal: true

# = VmScan
#
# Le modèle +VmScan+ représente un scan (ou tir) lancé par un ingénieur SOC
# Dans le cas des Vulnerability Management (Vm) :
#
# Le +VmScan+ est lié à un seul +VmReport+
# Le +VmScan+ est lié à plusieurs Target (les destinations du scan)
# Un +VmScan+ contient nécessairement une référence, un type, un titre (title), une durée, un état
# et une date de lancement.
class VmScan < Scan
  include KindConcern

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

  attribute :duration, :string

  has_many :report_vm_scans,
    class_name: 'ReportVmScan',
    inverse_of: :vm_scan,
    dependent: :delete_all

  has_many :reports,
    class_name: 'Report',
    foreign_key: :report_id,
    inverse_of: :vm_scans,
    through: :report_vm_scans

  has_many :target_scans,
    class_name: 'TargetScan',
    inverse_of: :scan,
    foreign_key: :scan_id,
    primary_key: :id,
    dependent: :delete_all

  has_many :targets, through: :target_scans

  has_many :occurrences,
    class_name: 'VmOccurrence',
    inverse_of: :scan,
    foreign_key: :scan_id,
    primary_key: :id,
    dependent: :destroy

  belongs_to :account,
    class_name: 'Account',
    primary_key: :id,
    inverse_of: :vm_scans,
    optional: true

  belongs_to :qualys_vm_client,
    class_name: 'QualysVmClient',
    primary_key: :id,
    inverse_of: :vm_scans,
    optional: true

  belongs_to :scan_import,
    class_name: 'ScanImport',
    primary_key: :id,
    foreign_key: :import_id,
    inverse_of: :vm_scans,
    optional: true

  validates :name, presence: true
  validates :duration, presence: true
  validates :status, presence: true

  def to_s
    name
  end

  def target_ids
    targets.pluck(:id)
  end
end
