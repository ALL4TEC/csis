# frozen_string_literal: true

# = WaOccurrence
#
# Le modèle +WaOccurrence+ représente le résultat d'un scan concernant une destination précise.
# Dans le cas des Web Applications (WA) :
#
# Le +WaOccurrence+ est lié à une vulnérabilité, la vulnérabilité correspondant au résultat.
# Le +WaOccurrence+ est lié à un seul +WaTarget+, une seule destination
# Un +WaOccurrence+ contient nécessairement un résultat : données resultantes du scan.

class WaOccurrence < Occurrence
  include KindConcern

  has_paper_trail

  has_many :aggregate_wa_occurrences,
    class_name: 'AggregateWaOccurrence',
    inverse_of: :wa_occurrence,
    dependent: :delete_all

  has_many :aggregates,
    class_name: 'Aggregate',
    foreign_key: :aggregate_id,
    inverse_of: :wa_occurrences,
    through: :aggregate_wa_occurrences

  belongs_to :vulnerability,
    class_name: 'Vulnerability',
    primary_key: :id,
    inverse_of: :wa_occurrences

  belongs_to :scan,
    class_name: 'WaScan',
    primary_key: :id,
    inverse_of: :occurrences

  attr_readonly :uri

  def real_target
    uri
  end
end
