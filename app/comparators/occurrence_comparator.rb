# frozen_string_literal: true

require 'tempfile'

# Provide methods to clone a wa or vm scan
# including nested objects (occurrences and targets)
class OccurrenceComparator
  ATTRIBUTES = {
    vm: %i[result netbios fqdn real_target vulnerability_id],
    wa: %i[result uri param content payload data real_target vulnerability_id]
  }.freeze

  class << self
    # Vérifie que 2 occurrences sont semblables pour pouvoir être rattachées au même agrégat
    # On vérifie donc uniquement les identifiants de vulnérabilités
    # @param **occurrence_one:** First occurrence to compare
    # @param **occurrence_two:** Second occurrence to compare
    # @param **similar_attr:** Attributes used for similarity comparison
    # @return a boolean
    def similar?(occurrence_one, occurrence_two, similar_attr = %i[vulnerability_id])
      similar_attr.all? do |attri|
        occurrence_one.send(attri) == occurrence_two.send(attri)
      end
    end

    # Vérifie l'égalité complète en termes d'attributes entre 2 occurrences
    # On vérifie donc que tous les attributs, excepté l'identifiant et les timestamps sont égaux
    def equal?(occurrence_one, occurrence_two)
      ATTRIBUTES[occurrence_one.kind_accro.to_sym].all? do |attri|
        occurrence_one.send(attri) == occurrence_two.send(attri)
      end
    end

    def equals?(occurrences_one, occurrences_two)
      occurrences_one.all? do |occurrence_one|
        occurrences_two.any? { |occurrence_two| equal?(occurrence_one, occurrence_two) }
      end
    end
  end
end
