# frozen_string_literal: true

class AggregateManager
  class << self
    def create_from_vulnerability_and_occurrences_and_report(vulnerability, occurrences, report)
      accro = occurrences.first.kind_accro
      kind = KindUtil.from_accro(accro)
      max_rank = Aggregate.where(report: report, kind: kind)
                          .order('rank desc').pick(:rank) || 0
      scope = occurrences.map(&:real_target).uniq.map(&:to_s).join("\r\n")
      Aggregate.create(
        vulnerability.slice(:title, :solution, :severity)
                     .merge(
                       report: report, description: vulnerability.diagnosis, scope: scope,
                       status: vulnerability.kind, kind: kind, rank: max_rank + 1,
                       "#{accro}_occurrences": occurrences
                     )
      )
    end

    # On crée un nouvel agrégat dans le rapport
    # en reprenant les informations de l'agrégat en paramètre
    # @param **aggregate:** Aggregate to duplicate
    # @param **merged:** Merged data
    # @return the newly created aggregate
    def duplicate(aggregate, data_to_merge = {})
      Aggregate.create!(
        aggregate.slice(:title, :description, :solution, :status, :severity, :kind, :actions)
                 .merge(data_to_merge)
      )
    end
  end
end
