# frozen_string_literal: true

class AggregateService
  class << self
    # @param **aggregate:** Aggregate to link
    # @param **occurrences:** Occurrences to link
    def link_occurrences_to_aggregate(aggregate, occurrences)
      occurrences.each do |occurrence|
        occurrence.add_aggregates([aggregate])
      end
    end

    # Creates one aggregate per grouped occurrences vulnerability using vulnerability informations
    # @param **grouped_occurrences:** Group_by(&:vulnerability) function returns
    # [Vunerability, [Occurrence, Occurrence, ...]]
    # @param **report**: Report to link new aggregate to
    # @return **created aggregate**
    def create_from_grouped_occurrences(grouped_occurrences, report)
      grouped_occurrences.each do |group|
        vulnerability = group.first
        occurrences = group.last
        AggregateManager.create_from_vulnerability_and_occurrences_and_report(
          vulnerability, occurrences, report
        )
      end
    end

    # Duplicates an aggregate in new_report with common occurrences
    # (=> similar = linked to same vulnerability) if any
    # @param **aggregate:** Aggregate to duplicate
    # @param **report:** report to duplicate aggregate into
    # @param **vm_occurrences:**
    # @param **wa_occurrences:**
    # @param **ranks:** Ranks hash to insert aggregate at
    def duplicate_aggregate_with_common_occurrences(
      aggregate, report, vm_occurrences, wa_occurrences, ranks
    )
      common_occurrences = AggregateService.select_occurrences_in_common(
        aggregate, vm_occurrences, wa_occurrences
      )
      return [ranks, vm_occurrences, wa_occurrences] if common_occurrences.empty?

      ranks[aggregate.kind.to_sym] += 1 # Incrémente le rank
      # On crée un nouvel agrégat dans le rapport
      new_aggregate = AggregateManager.duplicate(
        aggregate, { report: report, rank: ranks[aggregate.kind.to_sym] }
      )
      # On lie les occurrences communes avec ce nouvel agrégat
      AggregateService.link_occurrences_to_aggregate(new_aggregate, common_occurrences)
      # On supprime les occurrences en commun des occurrences passées en paramètre
      # pour le type du nouvel agrégat uniquement pour ne plus les prendre en compte par la suite
      vm_occurrences -= common_occurrences if aggregate.system_kind?
      wa_occurrences -= common_occurrences if aggregate.applicative_kind?
      [ranks, vm_occurrences, wa_occurrences]
    end

    # For each aggregate of aggregate_ids
    # Duplicate aggregate if common occurrence with report unaggregated ones
    # @param **report:** Report to duplicate aggregates into
    # @param **aggregate_ids:** Aggregates to duplicate
    def duplicate_aggregates_with_common_unaggregated_occurrences(report, aggregate_ids)
      # For each aggregate
      aggregate_ids.each do |aggregate_id|
        aggregate = Aggregate.find(aggregate_id)
        vm_occurrences = report.unaggregated_vms
        wa_occurrences = report.unaggregated_was
        ranks = ReportService.init_ranks(report)
        AggregateService.duplicate_aggregate_with_common_occurrences(
          aggregate, report, vm_occurrences, wa_occurrences, ranks
        )
      end
    end

    # List occurrences of aggregate.kind similar to (vm|wa)_occurrences
    # @param **aggregate:** Aggregate from which we compare occurrences
    # @param **vm_occurrences:** VmOccurrences to compare with
    # @param **wa_occurrences:** WaOccurrences to compare with
    # @return **selected common occurrences**
    def select_occurrences_in_common(aggregate, _vm_occurrences, _wa_occurrences)
      kind_accro = aggregate.kind_accro
      # Définition des lambda de similarité d'occurrences
      similar = AggregateLambda.only_similar_occurrence(aggregate, kind_accro)
      # Sélection des occurrences communes
      instance_eval("_#{kind_accro}_occurrences", __FILE__, __LINE__).select(&similar)
    end

    # Add occurrences of (vm|wa)_occurrences similar to those in aggregate into aggregate
    # @param **aggregate:** Aggregate from which we compare occurrences
    # @param **vm_occurrences:** VmOccurrences to compare with
    # @param **wa_occurrences:** WaOccurrences to compare with
    def add_similar_occurrences_to_aggregate(
      aggregate, vm_occurrences, wa_occurrences
    )
      common_occurrences = select_occurrences_in_common(aggregate, vm_occurrences, wa_occurrences)
      # Linking selected occurrences to aggregate
      AggregateService.link_occurrences_to_aggregate(aggregate, common_occurrences)
      # We remove used occurrences from the list to eliminate potential conflicts
      # vm_occurrences -= common_occurrences if aggregate.system_kind?
      # wa_occurrences -= common_occurrences if aggregate.applicative_kind?
      [vm_occurrences - common_occurrences, wa_occurrences - common_occurrences]
    end

    # Loop through aggregates to add similar occurrences
    # @param **aggregates:** Aggregates to loop through
    # @param **vm_occurrences:** VmOccurrences to compare with
    # @param **wa_occurrences:** WaOccurrences to compare with
    # @return **[vm_occurrences, wa_occurrences]**: Remaining unused occurrences
    def add_similar_occurrences(aggregates, vm_occurrences, wa_occurrences)
      aggregates.each do |aggregate|
        vm_occurrences, wa_occurrences = add_similar_occurrences_to_aggregate(
          aggregate, vm_occurrences, wa_occurrences
        )
      end
      [vm_occurrences, wa_occurrences]
    end

    # Permet de merger des agrégats dans un autre du même rapport
    # @param **target_aggregate:** Target aggregate
    # @param **aggregate_ids:** Aggregates to merge into the target
    # @return the modified version of the target aggregate
    def merge_aggregates(target_aggregate, aggregate_ids)
      scopes = []
      scopes += target_aggregate.scope.split("\r\n") if target_aggregate.scope
      Aggregate.find(aggregate_ids).each do |from_aggregate|
        scopes += merge_aggregate(target_aggregate, from_aggregate)
      end
      target_aggregate.scope = reify_scopes(scopes) if scopes.present?
      target_aggregate
    end

    # Merges aggregate data into another one
    # And discard from_aggregate
    # @param **target_aggregate:** Target aggregate to merge in
    # @param **from_aggregate:** Aggregate to merge data from
    # @return **from_aggregate scopes**
    def merge_aggregate(target_aggregate, from_aggregate)
      scopes = []
      return scopes if AggregatePredicate.same_id?(target_aggregate, from_aggregate) ||
                       !AggregatePredicate.same_report?(target_aggregate, from_aggregate)

      target_aggregate.vm_occurrences << from_aggregate.vm_occurrences
      target_aggregate.wa_occurrences << from_aggregate.wa_occurrences
      scopes = from_aggregate.scope.split("\r\n") if from_aggregate.scope
      from_aggregate.discard
      scopes
    end

    # Gestion du scope ("compact" & "- ['']" just in case)
    # @param **scopes:** Scopes to reify
    # @return **reified scopes**
    def reify_scopes(scopes)
      (scopes.compact.uniq - ['']).join("\r\n")
    end

    # Permet de déplacer des occurrences d'un agrégat de même rapport et de même type dans un autre
    # @param **aggregate:** Target aggregate
    # @param **occurrences_data:** Occurrences json data
    # { 'aggregate_id' => 'x', 'occurrence_id' => 'y' } to merge into the target
    # @return the modified version of the target aggregate
    def move_occurrences(target_aggregate, occurrences_data)
      kind_accro = target_aggregate.kind_accro
      occurrence_clazz = "#{kind_accro.capitalize}Occurrence".constantize
      occurrences_data.each do |occurrence_data|
        source_aggregate = Aggregate.find(occurrence_data['aggregate_id'])
        next if AggregatePredicate.same_id?(target_aggregate, source_aggregate) ||
                !AggregatePredicate.same_report?(target_aggregate, source_aggregate) ||
                !AggregatePredicate.same_kind?(target_aggregate, source_aggregate)

        # Using 'find_by' because 'find' raises ActiveRecord::RecordNotFound
        occurrence = occurrence_clazz.find_by(id: occurrence_data['occurrence_id'])
        next if occurrence.nil?

        # Move occurrence into target_aggregate
        target_aggregate.send(:"#{kind_accro}_occurrences") << occurrence
        # Remove occurrence from source aggregate
        source_aggregate.send(:"#{kind_accro}_occurrences").delete(occurrence)
      end
      target_aggregate
    end
  end
end
