# frozen_string_literal: true

require 'tempfile'

module Generators
  # Scan report generator
  class ScanReportGeneratorJob < ApplicationKubeJob
    include ReportGeneratorCommon
    include ReportGeneratorCommonCore

    # Map de constantes du background de l'historique des scans
    BG_HISTO = {
      system: 'BBFDFE',
      applicative: 'BDFB50'
    }.freeze

    def add_aggregates_data_to_summary_values(report, summary_values)
      each_aggregate_kind(:to_sym, [4, 0, 1]) do |kind, _i|
        @aggregates_report = report.aggregates.where(kind: kind, visibility: :shown).order(:rank)
        # On teste si il existe des aggregates pour ne pas générer inutilement des pages
        if @aggregates_report.present?
          summary_values.merge!(
            draw_vulnerabilities(
              kind,
              @aggregates_report,
              report.send(:"#{KindUtil.to_accro(kind)}_introduction")
            )
          )
        end
        Rails.logger.info "Generated; section='#{kind.capitalize} Vulnerabilities'"
      end
    end

    # Generation du rapport
    # @param report: Objet rapport contenant les données
    # @param path: chemin du nouveau document
    # @param archi: boolean indiquant si on génère aussi les infos d'architecture du tir
    # @param histo: boolean indiquant si on génère aussi l'historique des rapports
    def generate_pdf(report, path, archi = false, histo = false)
      gen_pdf(report, path) do |summary_values|
        architecture = archi ? gen_architecture(report) : []
        score_historic = gen_score_history(report, histo)
        previous_report = Report.where(
          'project_id = ? AND edited_at < ?',
          report.project_id,
          report.edited_at
        ).order('edited_at desc').first
        summary_values.merge!(managerial_summary(previous_report, report, score_historic))
        progressify(:managerial_summary)
        # Summary page creation, will fill-up at the end
        page_title(I18n.t('pdf.title.summary'), 'summary')
        summary_values.merge!(show_architecture(architecture)) unless architecture.empty?
        progressify(:architecture)
        add_aggregates_data_to_summary_values(report, summary_values)
      end
    end

    private

    # Build the first page
    def flyleaf(report, date, location)
      @pdf.move_down 20
      @pdf.text(
        "<b>#{I18n.t("pdf.#{report.type.downcase}.title.name").upcase} #{report.project.name}</b>",
        inline_format: true,
        align: :center,
        size: 30
      )
      @pdf.move_cursor_to 470
      @pdf.text I18n.t('models.report'), align: :center, size: 30
      @pdf.move_down 30
      img = if report.client_logo.attached?
              StringIO.open(report.client_logo.download)
            else
              reports_logo
            end
      @pdf.image img, position: :center, height: 150
      @pdf.move_down 40
      @pdf.text I18n.t('pdf.slogan'), align: :center, size: 20
      @pdf.move_down 5
      @pdf.text I18n.t('pdf.cyber_serenity'), align: :center, size: 20
      flyleaf_common(report, date, location)
    end

    # Build Confidentiality Page
    def preambule(report)
      page_title(I18n.t('pdf.preamble').to_s, 'preliminary')
      @pdf.move_down 20
      @pdf.text(
        "<color rgb=#{ORANGE}>#{I18n.t('pdf.classification.class_name')}:</color>" \
        "<color rgb=#{ORANGE_CONFIDENTIEL}>#{I18n.t(T_CONFIDENTIEL)}</color>",
        inline_format: true,
        align: :left,
        text_color: ORANGE_CONFIDENTIEL,
        size: 18
      )
      preambule_common(report)
    end

    # Print summary lines at right places
    def add_summary_line(x_index, anchor, page)
      @pdf.grid(x_index, 0).bounding_box do
        @pdf.text("<link anchor='#{anchor}'>- #{I18n.t("pdf.text.#{anchor}")}</link>",
          inline_format: true, size: 20)
      end
      @pdf.grid(x_index, 1).bounding_box do
        @pdf.text page.to_s, size: 20, align: :right
      end
    end

    # Build summary with correct titles with its pages numbers
    def summary(titles)
      @pdf.go_to_page 4

      @pdf.move_down 150
      @pdf.define_grid(columns: 2, rows: 9)

      titles.each_with_index do |(key, values), index|
        add_summary_line(index + 2, key, values[:page])
      end
    end

    # Show details of details
    def details(data, step)
      infos = []
      cell_style = { borders: [], size: 15 }
      data.each do |info|
        if info.is_a?(Array)
          @pdf.table(infos, position: step, cell_style: cell_style) unless infos.empty?
          details(info, step + 20)
          infos = []
        else
          infos << ['•', info]
        end
      end
      @pdf.table(infos, position: step, cell_style: cell_style) unless infos.empty?
    end

    # Print correctly architecture details
    def show_architecture(architecture)
      page_title(I18n.t('pdf.title.tested_architecture'), 'architecture')
      summary_infos = { architecture: { page: @pdf.page_number } }

      @pdf.move_cursor_to 500
      architecture.each do |point|
        @pdf.text point[0], size: 20
        details(point[1], 0)
        @pdf.move_down 20
      end

      summary_infos
    end

    # Print nothing if no diff
    # @param diff Nombre de nouvelles vulnerabilités
    # + in red if diff > 0 (:()
    # - in green if diff < 0 (:))
    def define_evolution(diff)
      return '' if diff.zero?

      color = diff.positive? ? 'C0392B' : '27AE60'
      sign = diff.positive? ? '+' : '-'
      "<font size='12'><b><color rgb='#{color}'>#{sign}</color></b></font> #{diff.abs}"
    end

    def draw_first_scores_table_no_diff(table_data, current_column, first_row, index, data)
      return if first_row == SCORING

      current_cell = table_data[current_column][index]
      data << if index == 5
                bold(current_cell)
              else
                current_cell.to_s
              end
    end

    def draw_first_scores_table(current_column, score_table_data, index, data)
      score_table_data.each do |table_data|
        first_row = table_data[0]
        if first_row == DIFF
          diff = data[data.length - 1].to_i - data[data.length - 2].to_i
          data << define_evolution(diff)
        else
          draw_first_scores_table_no_diff(table_data, current_column, first_row, index, data)
        end
      end
    end

    def draw_second_scores_table(score_table_data, index, data)
      score_table_data.each do |table_data|
        if table_data[0] == SCORING
          second_cell = table_data[1][index]
          data << (index == 5 ? bold(second_cell) : second_cell)
        end
      end
    end

    # Build correct score array to create score table
    def add_scores(score_table_data, name, index, type)
      data = []
      data << name
      nb_of_score_table_columns = columns_nb(type)
      1.upto(nb_of_score_table_columns) do |current_column|
        draw_first_scores_table(current_column, score_table_data, index, data)
      end
      draw_second_scores_table(score_table_data, index, data)
      data
    end

    def before_scores_table(table, nb_of_columns, col, vuln_color)
      table.before_rendering_page do |vulnerability_table|
        vulnerability_table.row(0).column(0).valign = :center
        vulnerability_table.row(0).column((nb_of_columns * 3) + 1).valign = :center
        vulnerability_table.row(2..6).column(0).align = :left
        vulnerability_table.row(2).column(0).text_color = WHITE
        vulnerability_table.row(2).column(col).text_color = WHITE
        vulnerability_table.row(3).column(0).text_color = WHITE
        vulnerability_table.row(3).column(col).text_color = WHITE
        vulnerability_table.row(6).column(0).text_color = WHITE
        vulnerability_table.row(6).column(col).text_color = WHITE
        fill_vulnerability_table_bg(vulnerability_table, col)
        vulnerability_table.row(-1).column(-1).background_color = vuln_color
      end
    end

    # Build vulnerabilities score table
    def build_vulnerabilities_table(vuln_color, score_table_data, type)
      column_size = score_table_data.count < 4 ? 2 : 3
      columns = [
        {
          content: bold(I18n.t(T_SEVERITY)),
          rowspan: 2
        },
        {
          content: bold(AggregatesHelper.translate_status(:vulnerability)),
          colspan: column_size
        },
        {
          content: bold(AggregatesHelper.translate_status(:potential_vulnerability)),
          colspan: column_size
        }
      ]
      nb_of_columns = columns_nb(type)
      if type == :system
        col = 10..11
        col_w = 13
        col_width = 44
        col_first_width = 47
        columns << {
          content: bold(AggregatesHelper.translate_status(:information_gathered)),
          colspan: column_size
        }
        str2 = sup(1)
        str = "#{str2} #{I18n.t('pdf.tab.not_this_line')}"
      else
        col = 13..14
        col_w = 16
        col_width = 36
        col_first_width = 31
        str2 = sup(2)
        columns += [
          {
            content: bold(
              AggregatesHelper.translate_status(:vulnerability_or_potential_vulnerability)
            ),
            colspan: column_size
          },
          {
            content: bold(
              AggregatesHelper.translate_status(:information_gathered) + str2
            ),
            colspan: column_size
          }
        ]
        str = "#{str2} #{I18n.t('pdf.tab.not_this_col')}"
      end
      columns += [
        { content: bold(I18n.t(T_TOTAL)), colspan: column_size },
        { content: bold(I18n.t(T_SCORING)), rowspan: 2 }
      ]

      # Fill dates
      dates = []
      nb_of_columns.times do
        score_table_data.each do |d|
          dates << d[0] unless d[0] == SCORING
        end
      end

      data = []
      data << columns
      data << dates
      # Add Scores
      [
        I18n.t(AggregatesHelper::T_IMMEDIATE_CORRECTION),
        I18n.t(AggregatesHelper::T_48H_CORRECTION),
        I18n.t(AggregatesHelper::T_MINOR_CORRECTION),
        I18n.t(AggregatesHelper::T_MAJOR_CORRECTION),
        I18n.t(AggregatesHelper::T_ILLIMITED_TIME) + str2,
        "<b>#{I18n.t('pdf.tab.total')}</b>"
      ].each_with_index do |translation, index|
        data << add_scores(score_table_data, translation, index, type)
      end

      @pdf.table(
        data,
        width: 700,
        position: 0,
        cell_style: {
          size: 9,
          border_width: 0.5,
          padding: [2, 5, 2, 5],
          align: :center,
          inline_format: true
        },
        column_widths: { 0 => 121, 1 => col_first_width, 2..col_w - 1 => col_width, col_w => 44 }
      ) do |table|
        before_scores_table(table, nb_of_columns, col, vuln_color)
      end

      @pdf.text_box(str, inline_format: true, size: 8, at: [200, @pdf.cursor - 10])
    end

    # Remplissage des couleurs de fond de la table de vulnerabilités
    def fill_vulnerability_table_bg(vulnerability_table, col)
      Vulnerability.severities.keys.reverse.map(&:to_sym).each_with_index do |sev, j|
        color = AggregatesHelper.color_fill_severity(sev)
        vulnerability_table.row(j + 2).column(0).background_color = color
        vulnerability_table.row(j + 2).column(col).background_color = color
      end
    end

    def historic_score_chart_series(score_historic)
      each_aggregate_kind(:to_s, [0, 1], to_map: true) { |k, i| add_serie(score_historic, k, i) }
      # En attente de scoring global y compris aggrégats organisationnels
    end

    # Build historic score chart
    def build_historic_score_chart(score_historic)
      labels = score_historic[0]
      series = historic_score_chart_series(score_historic)
      Rails.logger.info "Score Chart; series=#{series} labels=#{labels}"
      xaxis_labels = labels
      @pdf.graph series,
        theme: Prawn::Graph::Theme.new(series: [BG_HISTO[:system], BG_HISTO[:applicative]]),
        width: 370,
        height: 200,
        grid: 'F2F4F4',
        stroke_grid_lines: true,
        title: "Scoring #{sup(3)}",
        at: [710, 410],
        xaxis_labels: xaxis_labels
    end

    def history_aggregates_colors(page)
      each_aggregate_kind { |k, i| page.column(0).row(i + 1).background_color = BG_HISTO[k] }
    end

    def before_history_score_table(table)
      table.before_rendering_page do |page|
        page.column(0).align = :left
        page.row(0).background_color = 'D46B38'
        history_aggregates_colors(page)
      end
    end

    def add_score_to_data(score_historic, data, index)
      score_historic[index].each { |score| data << score }
    end

    def compute_history_score_data(score_historic)
      # TODO: Translate
      history_data = [['Historique Scoring'], ['Système'], ['Applicatif']]
      history_data.each_with_index { |data, i| add_score_to_data(score_historic, data, i) }
      history_data
    end

    # Build historic score table
    def build_history_score_table(score_historic)
      history_data = compute_history_score_data(score_historic)
      @pdf.table(
        history_data,
        width: 300,
        position: 730,
        cell_style: { size: 9, border_width: 0.5, padding: [1, 1, 1, 1], align: :center }
      ) do |table|
        before_history_score_table(table)
      end
    end

    def add_serie(score_historic, kind, index)
      Prawn::Graph::Series.new(score_historic[index + 1], title: I18n.t("pdf.title.#{kind}"))
    end

    def draw_vulnerabilities_table(previous_report, report)
      each_aggregate_kind do |k, i|
        @pdf.text I18n.t("pdf.text.#{k}"), inline_format: true, size: 17
        build_vulnerabilities_table(BG_HISTO[k], gen_score_table(previous_report, report, k), k)
        @pdf.move_down 30 if i.zero?
      end
    end

    # Creation of managerial summary : vulnerabilities score table,
    # historic table and historic chart
    def managerial_summary(previous_report, report, score_historic)
      date = if I18n.locale == :en
               report.edited_at.to_fs(:long_ordinal)
             else
               I18n.l report.edited_at, format: :long
             end
      page_title(I18n.t('pdf.text.managerial_summary'), 'managerial_summary')
      summary_infos = { managerial_summary: { page: @pdf.page_number } }

      @pdf.text(
        "#{report.project.client.name} / #{report.project.name} : " \
        "#{I18n.t("pdf.#{report.type.downcase}.managerial_summary.this_document")} #{date}.",
        size: 17
      )
      @pdf.text report.introduction.to_s, size: 17 if report.introduction.present?

      if report.is_a?(ScanReport)
        # Vulnerabilities Tables
        @pdf.move_cursor_to 420
        draw_vulnerabilities_table(previous_report, report)

        # History Score Chart
        build_historic_score_chart(score_historic)
        @pdf.move_down 40
        # History score table
        build_history_score_table(score_historic)
        @pdf.move_down 40
        @pdf.text_box("#{sup(3)} #{I18n.t('pdf.text.score_depends')}",
          inline_format: true, size: 8, at: [800, 120])
      end

      summary_infos
    end

    def add_titles_numbering(first_page_nb, last_page_nb, vuln_type, additionnel)
      current_page = first_page_nb - additionnel
      while current_page <= last_page_nb
        @pdf.go_to_page current_page
        @pdf.text vuln_type, size: 25
        @pdf.stroke_color 'B95D33'
        @pdf.line [0, 540], [@pdf.bounds.right, 540]
        @pdf.stroke
        @pdf.move_down 20
        @pdf.stroke_color BLACK
        used_pages = first_page_nb - 1 - additionnel
        @pdf.draw_text(
          "(#{current_page - used_pages}/#{last_page_nb - used_pages})", at: [900, 550], size: 25
        )
        current_page += 1
      end
    end

    def before_aggregates_table(table)
      table.before_rendering_page do |page|
        page.column(0).width = 125
        page.column(1).width = 25
        page.column(2).align = :justify
      end
    end

    def draw_aggregate(agg, last_status)
      @pdf.move_down 20
      @pdf.move_down 100 if @pdf.cursor < 100
      if agg.status != last_status
        @pdf.text("<b>#{translate_status(agg.status)}</b>",
          inline_format: true,
          size: 20)
        last_status = agg.status
      end
      curseur = @pdf.cursor
      @pdf.text(
        "<u>#{agg.title}</u> : ",
        inline_format: true,
        size: 18
      )
      curseur2 = @pdf.cursor
      @pdf.move_cursor_to curseur
      @pdf.cell(text_color: AggregatesHelper.color_text_severity(agg.severity),
        at: [800, curseur2 + 24],
        size: 12,
        width: 235,
        background_color: AggregatesHelper.color_fill_severity(agg.severity),
        content: AggregatesHelper.translate_severity(agg.severity),
        border_color: BLACK)
      @pdf.move_cursor_to curseur2

      aggregate_data = []
      aggregate_data << [I18n.t('labels.description'), ' ', agg.description]
      %i[solution scope].each do |label|
        value = agg.send(label)
        aggregate_data << [I18n.t("labels.#{label}"), ' ', value] if value.present?
      end
      @pdf.table(aggregate_data, cell_style: { borders: [], size: 14 }) do |table|
        before_aggregates_table(table)
      end
      last_status
    end

    def draw_aggregates(aggregates)
      last_status = ''
      aggregates.each do |agg|
        last_status = draw_aggregate(agg, last_status)
      end
    end

    # Create vulnerabilities pages : its introduction, descriptions and misc infos + page numbering
    def draw_vulnerabilities(vuln_type, aggregates, intro)
      pages_to_add = 0
      page_title(I18n.t("pdf.text.#{vuln_type}"), vuln_type.to_s)
      summary_infos = { vuln_type.to_sym => { page: @pdf.page_number } }

      if intro.present?
        @pdf.text intro, size: 25
        pages_to_add = 1
        page_title('', '')
      end
      first_page_nb = @pdf.page_number

      @pdf.bounding_box([10, 525], width: 1000, height: 470) do
        draw_aggregates(aggregates)
      end
      last_page_nb = @pdf.page_number
      add_titles_numbering(
        first_page_nb, last_page_nb, I18n.t("pdf.text.#{vuln_type}"), pages_to_add
      )

      summary_infos
    end

    # Generate last page and its message
    def last_page_message(note)
      page_title('', '')
      @pdf.move_cursor_to 500
      @pdf.text note.to_s, size: 17 if note.present?
      @pdf.move_down 40
      %w[full_list available_from_referent].each do |w|
        @pdf.text(
          "<b>#{I18n.t("pdf.text.#{w}")}</b>",
          size: 20,
          align: :center,
          inline_format: true
        )
      end
    end

    def gen_score_table_row(vulnerabilities)
      vulnerabilities = vulnerabilities.group_by(&:severity)
      counts = Vulnerability.severities.keys.reverse.map do |severity|
        (vulnerabilities[severity] || []).length
      end
      # [5, 4, 3, 2, 1, Total] # Sévérité
      counts.push(counts.sum)
    end

    def empty_table(aggregate_kind)
      table = ['', Array.new(6), Array.new(6), Array.new(6), Array.new(6)]
      table << Array.new(6) if aggregate_kind == :applicative
      table
    end

    def generated_table(report, aggregate_kind)
      table = [
        I18n.l(report.edited_at, format: '%-d %b'),
        gen_score_table_row(report.vulnerabilities(aggregate_kind, kind: :vulnerability))
      ]
      if aggregate_kind == :system
        table << gen_score_table_row(
          report.vulnerabilities(aggregate_kind, kind: :potential_vulnerability) +
          report.vulnerabilities(aggregate_kind, kind: :vulnerability_or_potential_vulnerability)
        )
      else
        table += [
          gen_score_table_row(report.vulnerabilities(aggregate_kind,
            kind: :potential_vulnerability)),
          gen_score_table_row(report.vulnerabilities(aggregate_kind,
            kind: :vulnerability_or_potential_vulnerability))
        ]
      end
      table + [
        gen_score_table_row(report.vulnerabilities(aggregate_kind, kind: :information_gathered)),
        gen_score_table_row(report.vulnerabilities(aggregate_kind))
      ]
    end

    def gen_score_table(previous_report, current_report, kind)
      prev_table = if previous_report.nil?
                     empty_table(kind)
                   else
                     generated_table(previous_report, kind)
                   end

      score = Vulnerability.severities.keys.reverse.map do |severity|
        current_report.scoring(kind, :scan, severity: severity)
      end
                           .push(current_report.scoring(kind, :scan))

      Rails.logger.info "Score table; final_scoring=#{score}"
      [
        prev_table,
        generated_table(current_report, kind),
        [DIFF],
        [SCORING, score]
      ]
    end

    def gen_score_history(report, histo)
      report.regenerate_scoring
      reports = if histo
                  Report.where(
                    'project_id = ? AND edited_at < ?',
                    report.project_id,
                    report.edited_at
                  ).order('edited_at DESC').limit(12).to_a.reverse
                else
                  []
                end
      reports << report
      history = [[], [], []]
      reports.each do |r|
        history[0] << I18n.l(r.edited_at, format: '%-d %b')
        history[1] << r.scoring_vm
        history[2] << r.scoring_wa
      end
      Rails.logger.info("Score history; data=#{history}")
      history
    end

    def get_vm_targets(report)
      vm_targets = []
      report.report_vm_scans.each do |report_vm_scan|
        if report_vm_scan.report_targets.present?
          vm_targets += report_vm_scan.report_targets.map(&:target)
        end
      end
      vm_targets
    end

    def get_wa_uri(report)
      wa_uri = []
      report.report_wa_scans.each do |report_wa_scan|
        next if (url = report_wa_scan.web_app_url).blank? &&
                (url = report_wa_scan.wa_scan.url).blank?

        ip = Vulnerability.where(qid: 6).first.wa_occurrences.where(scan: report_wa_scan.wa_scan)
        ip = if ip.present? && ip.first.result.present?
               " (#{ip.first.result.split("\n").last.split.first})"
             else
               ''
             end
        wa_uri << (url + ip)
      end
      wa_uri
    end

    # Affiche les informations d'architecture du projet
    def gen_architecture(report)
      res = []
      vm_targets = get_vm_targets(report)
      Rails.logger.info("Architecture; vm_targets=#{vm_targets}")
      unless vm_targets.empty?
        res << [
          I18n.t('pdf.text.server'),
          vm_targets.map { |t| t.ip.to_s }
        ]
      end

      wa_uri = get_wa_uri(report)
      Rails.logger.info("Architecture; wa_uri=#{wa_uri}")
      unless wa_uri.empty?
        res << [
          I18n.t('pdf.text.applications'),
          wa_uri.uniq
        ]
      end
      res
    end

    def yield_generate(export, filepath, archi, histo)
      generate_pdf(export.report, filepath, archi, histo)
    end

    def yield_histo(export)
      export.report.project.reports.map(&:regenerate_scoring)
      export.reload
    end

    # Lance la génération du pdf
    # @param export_id: identifiant d'export du pdf
    # @param archi: boolean indiquant si le rapport doit contenir les informations
    # d'architecture des scans
    def perform(export_id, archi, histo)
      handle_perform(9, export_id, archi, histo)
    end
  end
end
