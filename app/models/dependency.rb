# frozen_string_literal: true

#                   Modèle Denpendency
#
# Le modèle Dependency correspond à une dépendance entre deux actions. Cela
# permet de fournir au client/contact une hiérarchie ainsi qu'un ordre dans
# les actions à effectuer.

class Dependency < ApplicationRecord
  include DiscardWithPaperTrailEvents::Model

  # Le couple (successor, predecessor) doit être unique
  validates :successor_id, uniqueness: { scope: :predecessor_id }

  default_scope -> { kept }

  belongs_to :action_s,
    class_name: 'Action',
    inverse_of: :dependencies,
    foreign_key: 'successor_id',
    primary_key: :id

  belongs_to :action_p,
    class_name: 'Action',
    inverse_of: :roots,
    foreign_key: 'predecessor_id',
    primary_key: :id

  # Vérifie que ses actions sont bien undiscard avant de s'undiscard
  before_undiscard do
    false unless action_p.present? && action_s.present?
  end
end
