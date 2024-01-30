# frozen_string_literal: true

#                   Modèle Project
#
# Le modèle Project est lié à un Client, il correspond à l'un des projets de cette société cliente.
#
# Un Project est lié à plusieurs Report, les rapports qui ont déjà été lancés.
#
# Un Project est lié à plusieurs suppliers, ils correspondent aux sous-traîtants utilisés pour
# ce projet.
#
# Un Project est défini par son nom (name)

require 'rot13'

class Project < ApplicationRecord
  include EnumSelect
  include DiscardWithPaperTrailEvents::Model
  include ProjectScheduler

  default_scope -> { kept }
  scope :auto, -> { where(auto_generate: true) }

  after_create do
    if tmp_report_auto_generation_cron.present?
      tmp_report_auto_generation_cron.update!(cronable_id: id)
    end
    Statistic.create(project: self)
    Certificate.create(project: self)
    make_folder
    schedule_report_auto_generation if auto_generate
  end

  after_update do
    if auto_generate
      schedule_report_auto_generation
    else
      remove_report_auto_generation_schedule
    end
  end

  # Discard ses rapports avant d'être discardé
  before_discard do
    false unless reports.discard_all
  end

  after_discard do
    remove_report_auto_generation_schedule
  end

  # Undiscard ses rapports après avoir été undiscardé
  after_undiscard do
    false unless reports.trashed.undiscard_all
  end

  belongs_to :client,
    class_name: 'Client',
    primary_key: :id,
    inverse_of: :projects

  has_many :teams_projects,
    class_name: 'TeamProject',
    primary_key: :id,
    inverse_of: :project,
    dependent: :delete_all

  has_many :teams, through: :teams_projects
  has_many :staffs, -> { distinct }, through: :teams

  has_many :suppliances,
    class_name: 'Suppliance',
    inverse_of: :supplied_project,
    dependent: :delete_all

  has_many :suppliers,
    class_name: 'Client',
    foreign_key: :supplier_id,
    inverse_of: :supplied_projects,
    through: :suppliances

  has_many :suppliers_contacts,
    -> { distinct },
    through: :suppliers,
    source: :contacts

  def related_contacts
    User.union_all(client.contacts, suppliers_contacts).distinct.ordered_alphabetically
  end

  has_many :scheduled_scans,
    class_name: 'ScheduledScan',
    inverse_of: :project,
    primary_key: :id,
    dependent: :delete_all

  def report
    reports.order(edited_at: :desc).first if reports.present?
  end

  def last_report(type)
    reports.where(type: type).order(edited_at: :desc).first if reports.present?
  end

  has_many :reports,
    class_name: 'Report',
    inverse_of: :project,
    primary_key: :id,
    dependent: :delete_all

  has_one :statistics,
    class_name: 'Statistic',
    primary_key: :id,
    inverse_of: :project,
    dependent: :destroy

  delegate :current_level, to: :statistics

  has_one :certificate,
    class_name: 'Certificate',
    primary_key: :id,
    inverse_of: :project,
    dependent: :destroy

  belongs_to :language,
    class_name: 'Language',
    inverse_of: :projects,
    primary_key: :id,
    optional: true

  has_many :aggregates, through: :reports
  has_many :actions, -> { distinct }, through: :aggregates
  has_many :vm_scans, through: :reports
  has_many :wa_scans, through: :reports

  has_many :assets_projects,
    class_name: 'AssetProject',
    primary_key: :id,
    inverse_of: :project,
    dependent: :delete_all

  has_many :assets, through: :assets_projects

  def usable_vm_scans
    ScanService.common_accounts_scans_between_teams(teams, :vm).concat(vm_scans)
  end

  def usable_wa_scans
    ScanService.common_accounts_scans_between_teams(teams, :wa).concat(wa_scans)
  end

  # used to store cron created before project id is available...
  attr_accessor :tmp_report_auto_generation_cron

  enum_with_select :notification_severity_threshold,
    { trivial: 0, low: 1, medium: 2, high: 3, critical: 4 }, suffix: true

  validates :name, presence: true, length: {
    maximum: 100, message: I18n.t('projects.notices.length')
  }, uniqueness: { scope: [:client_id] }
  validates :teams, presence: true
  validates :auto_aggregate, inclusion: { in: [true, false] }
  validates :auto_generate, inclusion: { in: [true, false] }
  validates :scan_regex, presence: true, if: proc { |p| p.auto_generate? }

  validate :report_auto_generation_cron_presence, on: :create

  def to_s
    name
  end

  # Ransack
  class << self
    def ransackable_attributes(_auth_object = nil)
      %w[auto_aggregate auto_export auto_generate client_id created_at discarded_at folder_name id
         language_id name notification_severity_threshold scan_regex updated_at]
    end

    def ransackable_associations(_auth_object = nil)
      %w[actions aggregates assets assets_projects certificate client crons language reports
         scheduled_scans staffs statistics suppliances suppliers suppliers_contacts teams
         teams_projects versions vm_scans wa_scans]
    end

    def exportable_columns
      %w[name client created_at team]
    end
  end

  # Create a fname (folder's name) irreversible to find the client name from this
  # Need to be obfuscated because the certificate on client website will be taken from
  # the folder with this name
  # They made me write it, against my will.
  # I am not responsible of this code.
  def fname(param)
    if param == 'file'
      dir = Rot13.rotate(id.delete('-'))
      dir[5, 8] + dir[0, 4] + dir[24, 32] + dir[9, 23]
    elsif param == 'dir'
      id[4] + id[15] + id[5]
    else
      Rails.logger.debug('Wrong param type') # Should never happen
    end
  end

  # Create a folder with fname('dir') name, and create the default certificate in 2 dimensions
  # in this directory with the method fname('file')
  def make_folder
    path = AssetsUtil::WSC_DIR.join(fname('dir'))
    FileUtils.mkdir_p(path)
    # Copy certificates pictures
    FileUtils.cp(
      AssetsUtil::CERTIFICATES_DIR.join(certificate.path),
      File.join(path.to_s, "#{fname('file')}.png")
    )
    FileUtils.cp(
      AssetsUtil::CERTIFICATES_DIR.join(certificate.path.sub('_1x', '_2x')),
      File.join(path.to_s, "#{fname('file')}_2.png")
    )
  end
end
