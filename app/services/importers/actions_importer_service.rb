# frozen_string_literal: true

require 'csv'

module Importers
  class ActionsImporterService
    # @param job: job créé à l'initialisation du perform
    def initialize(job)
      @job = job
    end

    # Import actions from report_action_import document
    # @param **report_action_import:** ReportActionImport to link import to and to import from
    def import_actions(report_action_import)
      report_action_import.document.open do |file|
        @job.update!(status: :opening_document)
        handle_import(report_action_import, file)
        @job.update!(status: :update_status)
        report_action_import.action_import.update(status: :completed)
      end
    end

    def handle_import(report_action_import, file)
      Rails.logger.debug { "Opening file at: #{file.path}" }
      report = report_action_import.action_import.report
      CSV.foreach(file.path, encoding: 'ISO-8859-1', headers: true, col_sep: ';',
        quote_char: '"') do |row|
        aggregates = list_organizational_aggregates_from_report(report)
        selected_aggregate = if (aggregate_name = row['aggregate']).present?
                               aggregates.find { |agg| aggregate_name == agg.title }
                             end
        if selected_aggregate.nil?
          selected_aggregate = create_aggregate("org_#{SecureRandom.hex(10)}", aggregates, report)
        end
        create_action(row, selected_aggregate, report_action_import.action_import.importer)
      end
    end

    private

    def list_organizational_aggregates_from_report(report)
      report.aggregates.organizationals || []
    end

    def create_aggregate(aggregate_name, aggregates, report)
      Aggregate.create!(ActionsMapper.aggregate_h(aggregate_name, report, aggregates))
    end

    def check_row(row)
      state_ok = row['state'].present? && row['state'].in?(Action.states.keys)
      row['state'] = 'opened' unless state_ok
      meta_state_ok = row['meta_state'].present? && row['state'].in?(Action.meta_states.keys)
      row['meta_state'] = 'active' unless meta_state_ok
      priority_ok = row['priority'].present? && row['priority'].in?(Action.priorities.keys)
      row['priority'] = 'no' unless priority_ok
    end

    def create_action(row, selected_aggregate, importer)
      check_row(row)
      Action.create!(ActionsMapper.action_h(row, selected_aggregate, importer))
    end
  end
end
