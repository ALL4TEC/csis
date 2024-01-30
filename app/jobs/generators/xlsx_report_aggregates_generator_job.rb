# frozen_string_literal: true

module Generators
  class XlsxReportAggregatesGeneratorJob < ApplicationKubeJob
    ROWS = (Aggregate::SERIALIZED_ATTR - ['solution']).freeze

    private

    def save_to_file(export, stream)
      filename = "#{export.report.title.underscore}-#{Time.zone.now}"
      tmp = Tempfile.new([filename, '.xlsx'])
      File.open(tmp.path, 'w+b') do |f|
        f.write(stream.read)
        f.rewind
        blob = ActiveStorage::Blob.create_and_upload!(
          io: f,
          filename: "#{filename}.xlsx",
          content_type: 'xlsx',
          identify: false
        )
        export.update!(document: blob, status: 2)
      end
      tmp.unlink
    end

    def handle_xlsx_generation(export)
      report = export.report
      Axlsx::Package.new do |p|
        p.use_shared_strings = true
        wrap = p.workbook.styles.add_style alignment: { wrap_text: true }
        p.workbook.add_worksheet(name: report.title) do |sheet|
          sheet.add_row ROWS
          # Loop over ordered by rank report aggregates kind
          Aggregate::KIND_SCOPES.each do |scope|
            report.aggregates.visible.send(scope).order('rank asc').each do |agg|
              sheet.add_row customize_columns(agg), style: wrap
            end
          end
        end
        save_to_file(export, p.to_stream)
      end
    end

    # Concat aggregate solution after aggregate description in description column
    def customize_columns(aggregate)
      # cols = []
      serialized_values = aggregate.serializable_hash(only: Aggregate::SERIALIZED_ATTR)
      # Generate array from aggregate corresponding to wanted columns order
      ROWS.each_with_index do |key, index|
        cols[index] = if key == 'description'
                        "*** DESCRIPTION ***\r\n#{serialized_values[key]}\r\n" \
                          "*** SOLUTION ***\r\n#{serialized_values['solution']}"
                      elsif key == 'created_at'
                        I18n.l(serialized_values[key], format: :long)
                      else
                        serialized_values[key]
                      end
      end
      cols
    end

    def perform(export_id)
      report_export = ReportExport.find(export_id)
      job_h = {
        creator: report_export.exporter,
        progress_steps: 2,
        subscribers: report_export.report.project.staffs,
        title: "#{report_export.report.title}_xlsx_aggregates_export"
      }
      handle_perform(job_h, :update_report_export, report_export) do |job|
        job.update!(status: :generating_file)
        logger.debug "Xlsx export job started for report: #{report_export.report}"
        handle_xlsx_generation(report_export)
        job.update!(status: :completed)
        logger.debug "Xlsx export job for report #{report_export.report}: OK"
      end
    end

    def update_report_export(report_export)
      report_export.errored!
    end
  end
end
