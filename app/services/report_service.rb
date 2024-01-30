# frozen_string_literal: true

class ReportService
  VULN_SEV_DESC = 'vulnerability.severity desc'

  class << self
    # Initialize ranks hash containing last rank for each kind of aggregate in report
    # @param **report:** Report to init rank for
    # @return a hash { system: count, applicative: count }
    def init_ranks(report)
      {
        system: report.vm_aggregates.count,
        applicative: report.wa_aggregates.count
      }
    end

    # Duplicates aggregates with occurrences in common between 2 reports
    # At report creation vm_occurrences and wa_occurrences are specified from selected scans
    # Else we select occurrences of new report using all new_report targets
    # @param **new_report:**
    # @param **previous_report:**
    # @param **vm_occurrences:**
    # @param **wa_occurrences:**
    def duplicate_previous_common_aggregates(
      new_report, previous_report, vm_occurrences = nil, wa_occurrences = nil
    )
      # Find previous report aggregates
      previous_aggregates = Aggregate.includes(:wa_occurrences, :vm_occurrences)
                                     .where(report: previous_report)
                                     .order(:rank)
      ranks = init_ranks(new_report)
      # On parcourt la liste d'aggrégats du précédent rapport et on sélectionne
      # les occurrences en commun avec les nouvelles (passées en paramètres)
      # Si des occurrences sont en commun, alors on crée un nouvel agrégat que l'on lie aux
      # occurrences communes
      previous_aggregates.each do |aggregate|
        ranks, vm_occurrences, wa_occurrences =
          AggregateService.duplicate_aggregate_with_common_occurrences(
            aggregate, new_report, vm_occurrences, wa_occurrences, ranks
          )
      end
      [vm_occurrences, wa_occurrences]
    end

    # For each report of report_ids
    # For each aggregate of aggregate_ids
    # Duplicate aggregate if common occurrence with report unaggregated ones
    # @param **report_ids:** Reports to duplicate into
    # @param **aggregate_ids:** Aggregates to duplicate
    def bulk_duplicate_aggregates(report_ids, aggregate_ids)
      report_ids.each do |report_id|
        report = Report.find(report_id)
        AggregateService.duplicate_aggregates_with_common_unaggregated_occurrences(
          report, aggregate_ids
        )
      end
    end

    # Creates simple aggregates, one by vulnerability qid
    # Unaggregated occurrences are not fed to both functions because they change while running
    # @param **report:** Report to work on
    # @param **vm_o:** Remaining unaggregated vm occurrences
    # @param **wa_o:** Remaining unaggregated wa occurrences
    # @param **mixing:** If mixing is true, look at existing aggregates and feed them with similar
    # occurrences
    def auto_aggregate_occurrences(report, vm_o = nil, wa_o = nil, mixing = true)
      vm_o ||= VmOccurrence.in(report.unaggregated_vms)
      wa_o ||= WaOccurrence.in(report.unaggregated_was)
      # Edit previous aggregates
      vm_o, wa_o = feed_existing_aggregates(report, vm_o, wa_o) if mixing
      # Create new aggregates
      KindUtil.scan_accros.each do |kind|
        occs = kind == :vm ? vm_o : wa_o
        AggregateService.create_from_grouped_occurrences(
          group_unaggregated_occurrences(kind, report, occs), report
        )
      end
    end

    # Copy common occurrences between 2 reports
    # and automatically aggregate unaggregated others
    # among either only selected ones passed as parameter or all available unaggregated ones
    # @param **new_report:**
    # @param **previous_report:**
    # @param **vm_o:** VmOccurrences
    # @param **wa_o:** WaOccurrences
    def handle_occurrences(new_report, previous_report, vm_o = nil, wa_o = nil)
      previous = previous_report.present?
      if previous
        vm_o ||= OccurrenceService.select_vm_occurrences(
          new_report.class, new_report.vm_scan_ids, new_report.targets
        )
        wa_o ||= OccurrenceService.select_wa_occurrences(new_report.wa_scan_ids)
        vm_o, wa_o = duplicate_previous_common_aggregates(new_report, previous_report, vm_o, wa_o)
      end
      return unless new_report.project.auto_aggregate?

      auto_aggregate_occurrences(new_report, vm_o, wa_o, !previous)
    end

    private

    # @param **kind:** Aggregate status in :wa | :vm
    # @param **report:** Report to fetch unaggregated occurrences from
    # @param **occs:** Restrained occurrences from targets selection
    def group_unaggregated_occurrences(kind, report, occs)
      unaggregated = occs || report.send(:"unaggregated_#{kind}s")
      clazz = "#{kind.capitalize}Occurrence".constantize
      clazz.in(unaggregated).includes(:vulnerability).order(VULN_SEV_DESC)
           .group_by(&:vulnerability)
    end

    # Look at existing report aggregates and add them similar unaggregated occurrences
    # @param **report:** Report to fetch unaggregated occurrences from
    # @param **vm_o:** Restrained VmOccurrences from targets selection
    # @param **wa_o:** Restrained WaOccurrences from targets selection
    # @return **[vm_occurrences, wa_occurrences]:** Remaining unused occurrences
    def feed_existing_aggregates(report, vm_occurrences = nil, wa_occurrences = nil)
      # Find previous report aggregates & unaggregated occurrences
      aggregates = Aggregate.includes(:wa_occurrences, :vm_occurrences)
                            .where(report: report)
                            .order(:rank)
      # Find & Select occurrences with same vulnerabilities
      AggregateService.add_similar_occurrences(
        aggregates, vm_occurrences, wa_occurrences
      )
    end
  end
end
