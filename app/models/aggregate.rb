# frozen_string_literal: true

# = Aggregate
#
# Le modèle +Aggregate+ représente une partie du rapport de vulnérabilités.
# Un agrégat permet de regrouper des occurrences afin de générer un rapport bien organisé
# qui abstrait les failles en blocs plus haut-niveau et moins axés technique pure.
#
# Un agrégat est définit par ton titre.
# Le status correspond aux status des différentes occurrences liées à l'agrégat.

class Aggregate < ApplicationRecord
  include DiscardWithPaperTrailEvents::Model
  include EnumSelect
  include ActiveModel::Serializers::JSON

  SERIALIZED_ATTR = %w[id title description solution status severity kind rank scope impact
                       complexity created_at].freeze
  KIND_SCOPES = %w[vms was organizationals].freeze

  # Discard ses actions avant d'être discardé, supprime les liens avec les occurrences
  before_discard do
    false unless actions.discard_all && aggregate_vm_occurrences.delete_all &&
                 aggregate_wa_occurrences.delete_all
  end

  # Change les ranks pour ne pas avoir de problèmes d'ordre
  after_discard do
    # Les agrégats discardés ont un rank négatif pour éviter les conflits avec les actifs
    new_rank = Aggregate.trashed.where(report: report, kind: kind).pluck(:rank).min || 0
    new_rank = 0 unless new_rank.present? && new_rank.negative?
    update_columns(rank: new_rank - 1)

    Aggregate.where(report: report, kind: kind)
             .order('rank ASC').each_with_index do |a, i|
      a.update_columns(rank: i + 1)
    end
  end

  # Undiscard ses actions avant d'être undiscard
  before_undiscard do
    if actions.trashed.undiscard_all
      new_rank = Aggregate.with_discarded.kept.where(report: report, kind: kind).pluck(:rank).max
      new_rank = 0 unless new_rank.present? && new_rank.positive?
      update_columns(rank: new_rank + 1)
    else
      false
    end
  end

  # Si le type de l'agrégat est changé, les ranks sont mis à jours pour
  # s'assurer qu'ils se suivent.
  before_update do
    if will_save_change_to_attribute?(:kind) && !will_save_change_to_attribute?(:rank)
      max_rank = Aggregate.where(report: report, kind: kind).pluck(:rank).max || 0
      update_columns(rank: max_rank + 1, kind: kind)

      Aggregate.where(report: report).where.not(kind: kind).where.not(id: id)
               .order('rank ASC').each_with_index do |a, i|
        a.update_columns(rank: i + 1)
      end
    end
  end

  before_save do
    StringUtil.remove_html(description) if description.present?
    StringUtil.remove_html(solution) if solution.present?
  end

  default_scope -> { kept }
  belongs_to :report,
    class_name: 'Report',
    inverse_of: :aggregates,
    primary_key: :id

  has_many :aggregate_references,
    class_name: 'AggregateReference',
    inverse_of: :aggregate,
    primary_key: :id,
    dependent: :delete_all

  has_many :references, through: :aggregate_references

  has_many :aggregate_vm_occurrences,
    class_name: 'AggregateVmOccurrence',
    inverse_of: :aggregate,
    dependent: :delete_all

  has_many :vm_occurrences,
    class_name: 'VmOccurrence',
    foreign_key: :vm_occurrence_id,
    inverse_of: :aggregates,
    through: :aggregate_vm_occurrences

  has_many :aggregate_wa_occurrences,
    class_name: 'AggregateWaOccurrence',
    inverse_of: :aggregate,
    dependent: :delete_all

  has_many :wa_occurrences,
    class_name: 'WaOccurrence',
    foreign_key: :wa_occurrence_id,
    inverse_of: :aggregates,
    through: :aggregate_wa_occurrences

  has_many :aggregate_actions,
    class_name: 'AggregateAction',
    inverse_of: :aggregate,
    primary_key: :id,
    dependent: :delete_all

  has_many :actions, through: :aggregate_actions

  has_many :contents,
    class_name: 'AggregateContent',
    inverse_of: :aggregate,
    primary_key: :id,
    dependent: :destroy

  enum_with_select :status, {
    information_gathered: 0,
    vulnerability: 1,
    potential_vulnerability: 2,
    vulnerability_or_potential_vulnerability: 3
  }

  enum_with_select :severity, {
    falsepositive: 0, trivial: 1, low: 2, medium: 3, high: 4, critical: 5
  }, suffix: true

  enum_with_select :kind, {
    system: 0,
    applicative: 1,
    vulnerability_scan: 2,
    appendix: 3,
    organizational: 4
  }, suffix: true

  enum_with_select :visibility, { shown: 0, hidden: 1 }, suffix: true

  validates :title, presence: true
  validates :kind, presence: true
  validates :severity, presence: true
  validates :status, presence: true
  validates :visibility, presence: true

  scope :not_false_positive, -> { where.not(severity: :falsepositive) }
  scope :vms, -> { where(kind: :system) }
  scope :was, -> { where(kind: :applicative) }
  scope :organizationals, -> { where(kind: :organizational) }
  scope :visible, -> { where(visibility: :shown) }

  class << self
    # Ransack
    def ransackable_attributes(_auth_object = nil)
      %w[complexity created_at description discarded_at id impact kind rank report_id scope
         severity solution status title updated_at visibility]
    end

    def ransackable_associations(_auth_object = nil)
      %w[actions aggregate_actions aggregate_references aggregate_vm_occurrences
         aggregate_wa_occurrences contents references report versions
         vm_occurrences wa_occurrences]
    end

    def ordered_statuses
      [0, 3, 2, 1].to_h { |n| Aggregate.statuses.to_a[n] }
    end

    def by_status_desc
      Arel.sql(
        'case
       when status = 1 then 0
       when status = 2 then 1
       when status = 3 then 2
       else 3 end'
      )
    end
  end

  def severity_to_i
    Aggregate.severities[severity]
  end

  def to_s
    title
  end

  def occurrences
    Vulnerability.kinds.keys.map do |kind|
      sys_occurrences = OccurrenceService.select_occurrences_of_vulnerability_kind(
        vm_occurrences, kind
      )
      app_occurrences = OccurrenceService.select_occurrences_of_vulnerability_kind(
        wa_occurrences, kind
      )
      occurrences = OccurrenceService.sort_by_severity(sys_occurrences + app_occurrences)
      {
        title: I18n.t("activerecord.attributes.vulnerability/kind.#{kind}"),
        kind: kind,
        occurrences: occurrences
      }
    end
  end

  # Toggle visibility: shown <=> hidden
  def toggle_visibility
    self.visibility = Aggregate.visibilities.except(visibility).keys.first
    save
  end

  def kind_accro
    KindUtil.to_accro(kind)
  end

  def potential_receivers
    receivers = [['', '']]
    receivers += UserDecorator.decorate_collection(report.project.related_contacts)
                              .map do |decorated_contact|
      [decorated_contact.full_name_and_email, decorated_contact.object.id]
    end
    receivers
  end
end
