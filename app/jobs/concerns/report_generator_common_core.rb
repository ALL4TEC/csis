# frozen_string_literal: true

module ReportGeneratorCommonCore
  extend ActiveSupport::Concern

  included do
    # Generation du rapport
    # @param report: Objet rapport contenant les données
    # @param path: chemin du nouveau document
    # @param archi: boolean indiquant si on génère aussi les infos d'architecture du tir
    # @param histo: boolean indiquant si on génère aussi l'historique des rapports
    def gen_pdf(report, path)
      Prawn::Font::AFM.hide_m17n_warning = true
      Prawn::Document.generate(
        path,
        page_layout: :landscape,
        page_size: [612, 1088],
        margin: [20, 20, 20, 20]
      ) do |pdf|
        # On stocke le document dans une variable d'instance pour pouvoir
        # appeler nos méthodes d'instance du Report::Generator dans ce block
        @pdf = pdf
        @pdf.font 'Helvetica'
        edited_at = report.edited_at
        year = edited_at.strftime('%Y')
        day = edited_at.strftime('%d')
        month_number = edited_at.strftime('%m')
        month = I18n.l(edited_at, format: '%B')

        if I18n.locale == :en
          date_flyleaf = edited_at.to_fs(:long_ordinal)
          date_footer =  "#{month_number}/#{day}/#{year}"
        else
          date_flyleaf = I18n.l edited_at, format: :classic
          date_footer = "#{day}/#{month_number}/#{year}"
        end

        summary_values = {}
        signatory_town = Customization.get_value('signatory_town') ||
                         I18n.t('certificate.pdf.signatory_town')
        flyleaf(report, date_flyleaf, signatory_town)
        progressify(:flyleaf)
        preambule(report)
        progressify(:preambule)
        yield(summary_values)
        last_page_message(report.addendum)
        progressify(:last_page)
        footer(report, "#{month} #{year}", date_footer)
        progressify(:footer)
        summary(summary_values)
        progressify(:summary)
        page_numbering
        progressify(:numerotation)
      end
    end
  end

  private

  def handle_perform(steps, export_id, archi = false, histo = false)
    tmpdir = Dir.mktmpdir(['pdf-export', export_id])
    filepath = File.join(tmpdir, 'export.pdf')
    tmplang = I18n.locale
    begin
      export = ReportExport.includes(:report).find(export_id)
      creator = export.exporter
      receivers = export.report.project.staffs
      @job = Job.create!(
        resque_job_id: job_id, status: :init, clazz: self.class,
        creator: creator, subscribers: receivers, progress_steps: steps
      )
      Rails.logger.info "Generate PDF; export_id=#{export_id}"
      export.processing!
      Rails.logger.info 'Update export; status=processing'
      export.save

      yield_histo(export) if histo

      report = export.report
      I18n.locale = report.language.iso if report.language.present?
      yield_generate(export, filepath, archi, histo)
    rescue StandardError => e
      Rails.logger.error "#{self.class}: Error #{e.message}"
      @job.update!(status: :error, stacktrace: e.message)
      export = ReportExport.includes(:report).find(export_id)
      export.errored!
      export.save
      raise
    else
      File.open(filepath) do |f|
        blob = ActiveStorage::Blob.create_and_upload!(
          io: f,
          filename: "#{report.edited_at}_#{report.project.client.name}_" \
                    "#{report.project}" + I18n.t("pdf.#{report.type.downcase}.title.filename"),
          content_type: 'application/pdf'
        )
        export.update!(document: blob, status: 2)
      end
      @job.update!(status: :completed)
    ensure
      FileUtils.rm(filepath) if File.file?(filepath)
      FileUtils.remove_entry(tmpdir)
    end
    I18n.locale = tmplang
  end

  # Provide a loop over Aggregate.kinds.keys.map(&map) with index to use or not
  # **@param map:** method symbol to be applied on keys, default to :to_sym
  # **@param kinds_ary:** Kinds indexes to include, default to [0, 1] (System, applicative)
  # **@param to_map:** Boolean indicating if we need to map on each_with_index, default to false
  def each_aggregate_kind(map = :to_sym, kinds_ary = [0, 1], to_map: false)
    data = Aggregate.kinds.keys.values_at(*kinds_ary).map(&map)
    if to_map
      data.each_with_index.map { |k, i| yield(k, i) if block_given? }
    else
      data.each_with_index { |k, i| yield(k, i) if block_given? }
    end
  end
end
