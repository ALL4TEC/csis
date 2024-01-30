# frozen_string_literal: true

# = Target
#
# Le modèle +Target+ représente une cible atteignable depuis le réseau.
# En VM, le réseau inclut internet + de potentiels réseaux privés
# En WA, le réseau inclut uniquement le réseau public(internet)
# Dans le cas des Vulnerability Management (VM), les cibles sont donc des adresses IP
# (ou FQDN: TODO)
# Dans le cas des Web Application (WA), les cibles sont des URIs => inclut FQDN.
#
# Une +Target+ est liée à plusieurs +Scan+
# Une +Target+ est liée à plusieurs +Occurrences+
# Une +Target+ contient nécessairement une adresse IP ou une URL, qui correspond à la cible.

require 'resolv'

class Target < ApplicationRecord
  include KindConcern
  include DiscardWithPaperTrailEvents::Model

  KINDS = %w[VmTarget WaTarget].freeze
  KINDS_ATTRIBUTES = {
    'VmTarget' => :ip,
    'WaTarget' => :url
  }.freeze

  has_paper_trail

  scope :vm_targets, -> { where(kind: 'VmTarget') }
  scope :wa_targets, -> { where(kind: 'WaTarget') }

  has_many :target_scans,
    class_name: 'TargetScan',
    inverse_of: :target,
    dependent: :delete_all

  has_many :vm_scans,
    through: :target_scans,
    source_type: 'VmScan',
    source: :scan

  has_many :wa_scans,
    through: :target_scans,
    source_type: 'WaScan',
    source: :scan

  has_many :report_targets,
    class_name: 'ReportTarget',
    primary_key: :id,
    inverse_of: :target,
    dependent: :delete_all

  has_many :assets_targets,
    class_name: 'AssetTarget',
    primary_key: :id,
    inverse_of: :target,
    dependent: :delete_all

  has_many :assets, through: :assets_targets

  validates :name, presence: true
  validates :kind,
    inclusion: { in: KINDS }
  validates :ip, format: { with: Resolv::IPv4::Regex },
    unless: proc { |ifc| ifc.ip_before_type_cast.blank? }

  def self.ransackable_attributes(_auth_object = nil)
    %w[created_at discarded_at id ip kind name reference_id updated_at url]
  end

  def self.kinds_select
    KINDS
  end

  def to_s
    val = kind == 'VmTarget' ? ip.to_s : url
    val = name if val.blank?
    val
  end
end
