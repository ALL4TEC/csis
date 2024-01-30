# frozen_string_literal: true

#                   Modèle Action
#
# Le modèle Action permet de définir une tâche à effectuer par un contact dans le but de
# corriger une ou plusieurs vulnérabilités.

class Action < ApplicationRecord
  include DiscardWithPaperTrailEvents::Model
  include EnumSelect

  validates :state, presence: true
  validates :meta_state, presence: true
  validates :name, presence: true

  after_initialize :default_data

  # Vérifie l'état des dépendances avant de mettre à jour son propre état
  before_update do
    if will_save_change_to_attribute?(:state)
      cond1 = fixed_vulnerability? && action_p.where.not(state: 3).present?
      cond2 = to_fix? && action_p.where(state: 0).present?
      throw(:abort) if cond1 || cond2
    end
  end

  after_update do
    if saved_change_to_attribute?(:state)
      receivers = [author, receiver]
      BroadcastService.notify(receivers, :action_state_update, versions.last)
    end
  end

  # Discard ses dépendances avant d'être discardée
  before_discard do
    # dependencies.discard_all et roots.discard_all modifient la dépendance,
    # il est nécessaire de passer par cette solution moins esthétique
    links = dependencies.ids | roots.ids
    false unless Dependency.find(links).each(&:discard)
  end

  # Vérifie que son agrégat n'est pas discardé avant d'être undiscardée
  before_undiscard do
    false if aggregate.blank?
  end

  # Undiscard ses dépendances après avoir été undiscardée
  after_undiscard do
    # Même problème que pour before_discard
    links = dependencies.trashed.ids | roots.trashed.ids
    false unless Dependency.trashed.find(links).each(&:undiscard)
  end

  default_scope { kept }
  # default_scope -> {where.not(meta_state: 'archivée')}
  scope :all_except, ->(action) { where.not(id: action) }
  scope :to_correct, -> { where.not(state: 0) }

  # Ransack
  class << self
    def ransackable_attributes(_auth_object = nil)
      %w[author_id created_at description discarded_at due_date id meta_state name pmt_name
         priority receiver_id state updated_at]
    end

    def ransackable_associations(_auth_object = nil)
      %w[action_import action_p action_s aggregate aggregate_action aggregate_actions aggregates
         author comments dependencies issues receiver roots ticketables versions]
    end

    # Permet de savoir quelles colonnes sont exportables. Le tableau n'est pas dans une constante
    # parce que si elles ont toutes le même non, elles s'overrident.
    def exportable_columns
      %w[name state meta_state description created_at due_date pmt_name]
    end
  end

  has_many :aggregate_actions,
    -> { order(created_at: :desc) },
    class_name: 'AggregateAction',
    inverse_of: :action,
    foreign_key: :action_id,
    primary_key: :id,
    dependent: :delete_all

  has_many :aggregates, through: :aggregate_actions
  has_one :aggregate_action,
    -> { order(created_at: :desc) },
    class_name: 'AggregateAction',
    inverse_of: :action,
    foreign_key: :action_id,
    dependent: :delete
  has_one :aggregate, through: :aggregate_action # last

  delegate :severity, to: :aggregate, allow_nil: true
  delegate :report, to: :aggregate, allow_nil: true
  delegate :project, to: :report, allow_nil: true
  delegate :client, to: :project, allow_nil: true

  belongs_to :receiver,
    class_name: 'User',
    inverse_of: :received_actions,
    primary_key: :id,
    optional: true

  belongs_to :author,
    class_name: 'User',
    inverse_of: :authored_actions,
    primary_key: :id

  belongs_to :action_import,
    class_name: 'ActionImport',
    inverse_of: :imported_actions,
    primary_key: :id,
    optional: true

  has_many :comments,
    class_name: 'Comment',
    inverse_of: :action,
    primary_key: :id,
    dependent: :destroy

  has_many :dependencies,
    class_name: 'Dependency',
    inverse_of: :action_s,
    foreign_key: :predecessor_id,
    primary_key: :id,
    dependent: :destroy

  has_many :action_s, through: :dependencies

  has_many :roots,
    class_name: 'Dependency',
    inverse_of: :action_p,
    foreign_key: :successor_id,
    primary_key: :id,
    dependent: :destroy

  has_many :action_p, through: :roots

  has_many :issues,
    class_name: 'Issue',
    inverse_of: :action,
    dependent: :destroy

  has_many :ticketables, through: :issues,
    source_type: 'Account'

  # TODO: pour changer le receiver : le nouveau receiver doit être au moins dans les mêmes équipes
  # que l'ancien

  enum_with_select :state, {
    opened: 0,
    to_fix: 1,
    assigned: 2,
    fixed_vulnerability: 3,
    accepted_risk_not_fixed: 5,
    not_fixed: 6,
    reviewed_fix: 7,
    reopened: 8
  }

  enum_with_select :meta_state, { active: 0, clotured: 1, archived: 2 }
  enum_with_select :due_date_status, { no_due_date: 0, overdue: 1, to_do_today: 2, on_time: 3 }
  enum_with_select :priority, { no: 0, low: 1, medium: 2, high: 3 }, suffix: true

  scope :no_due_date, -> { where(due_date: nil) }
  scope :overdue, -> { where('due_date < ?', Time.zone.today.beginning_of_day) }
  scope :to_do_today, lambda {
    where(
      'due_date <= ? and due_date >= ?',
      Time.zone.today.end_of_day, Time.zone.today.beginning_of_day
    )
  }
  scope :on_time, -> { where('due_date > ?', Time.zone.today.end_of_day) }
  scope :closed, -> { union(Action.clotured, Action.archived, Action.discarded) }

  # existing issues (sorted by pmt_ref then by status so that open issues appear first)
  def sorted_opened_issues
    issues.sort_by(&:pmt_reference).sort_by { |i| i.status == 'open' ? 0 : 1 }
  end

  def closed?
    ActionPredicate.closed?(self)
  end

  def due_date_status
    closed? ? closed_due_date_status : opened_due_date_status
  end

  # Status d'échéance en fonction de la date d'échéance
  # Convertit due_date en due_date_status
  def opened_due_date_status
    return 'no_due_date' if due_date.nil?
    return 'on_time' if due_date > Time.zone.today.end_of_day
    return 'overdue' if due_date < Time.zone.today.beginning_of_day

    'to_do_today'
  end

  # Status d'échéance en fonction de la date d'échéance comparée à la date de dernière mise ç jour
  # de l'action: clotured, archived ou trashed set updated_at
  # TODO: Vérifier que discard set updated_at...
  def closed_due_date_status
    return 'on_time' if due_date.nil?
    return 'overdue' if due_date < updated_at.beginning_of_day

    'on_time'
  end

  # Modification du "meta_state" en fonction du "state"
  def update_meta
    update(meta_state: if state.in?([:reviewed_fix.to_s, :accepted_risk_not_fixed.to_s])
                         1
                       else
                         0
                       end)
  end

  # Liste les possibilités de dépendances
  # de l'action instanciée
  def potential_deps
    potential_deps = aggregate.actions.all_except(self)
    pred = action_p
    succ = action_s
    potential_deps -= pred unless pred.nil?
    potential_deps -= succ unless succ.nil?
    potential_deps.each do |act|
      # On garde l'action comme dépendance si et seulement si c'est un predecesseur
      # ET? un successeur de l'action courante...
      potential_deps -= Array(act) unless act.succ?(id) && act.pred?(id)
    end
    potential_deps
  end

  # Vérifie si une action fait partie des successeurs de l'action courante
  def succ?(action_id)
    ActionPredicate.successor?(self, action_id)
  end

  # Vérifie si une action fait partie des prédécesseurs de l'action courante
  def pred?(action_id)
    ActionPredicate.predecessor?(self, action_id)
  end

  # Liste les utilisateurs qui ont utilisé la messagerie interne
  def reviewers
    comments.map(&:author)
  end

  def to_s
    name
  end

  private

  def default_data
    # Ne set les donnees par defaut que si les attributs sont vides
    self.state ||= :ouverte
    self.meta_state ||= :active
  end
end
