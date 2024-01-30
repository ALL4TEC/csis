# frozen_string_literal: true

module Generators
  # Generate certificate
  class CertificateGeneratorJob < ApplicationKubeJob
    # Assets style
    BG_COLOR = 'e1e1e1' # Behind numbers on page 2
    FONT = 'Roboto'
    CERTIFICATES_URL = '' # TODO: customize
    CERTIFICATE_LINK = "<link href='#{CERTIFICATES_URL}'>#{CERTIFICATES_URL}</link>".freeze
    # Used to have default values in settings page
    BASIC_TEXT = BLACK
    TITLE_TEXT = WHITE
    HIGHLIGHTED_TEXT = ORANGE
    INFORMATIVE_TEXT = GREY

    # Translations
    T_DATE_THE = 'certificate.pdf.the'
    T_DATE_SINCE = 'certificate.pdf.since'

    # Set date for one or multiple reports
    def date(times)
      if times == 1
        I18n.t(T_DATE_THE)
      else
        I18n.t(T_DATE_SINCE)
      end
    end

    # Document pages format
    PAGE = {
      size: [720, 1280],
      layout: :landscape,
      margin: [20, 20, 20, 20]
    }.freeze

    NOFS_AT = {
      nof_very_good: [675, 650],
      nof_excellent: [250, 650],
      nof_good: [300, 525],
      nof_satisfactory: [625, 525],
      nof_in_progress: [460, 400]
    }.freeze

    CERT = {
      in_progress: {
        text_color: WHITE,
        at: [260, 400],
        bg_color: Styles::SEVERITY_COLORS[0].delete('#')
      },
      satisfactory: {
        text_color: WHITE,
        at: [425, 525],
        bg_color: Styles::SEVERITY_COLORS[1].delete('#')
      },
      good: {
        text_color: BLACK,
        at: [100, 525],
        bg_color: Styles::SEVERITY_COLORS[2].delete('#')
      },
      very_good: {
        text_color: BLACK,
        at: [475, 650],
        bg_color: Styles::SEVERITY_COLORS[3].delete('#')
      },
      excellent: {
        text_color: WHITE,
        at: [50, 650],
        bg_color: Styles::SEVERITY_COLORS[4].delete('#')
      }
    }.freeze

    # @return web_app_urls
    def add_web_app_urls(reports, data)
      tmp = reports.flat_map(&:wa_scans).flat_map(&:url).uniq - [nil]
      tmp.each do |wau|
        data << ["<link href='#{wau}'>#{wau}</link>"]
      end
      tmp
    end

    # Génération du rapport
    # @param project: Objet projet contenant les données
    # @param path: chemin du nouveau certificat
    # @param transparency: project certificate transparency level
    def generate_pdf(project, path, transparency)
      # Using explicit block form and rendering to a file
      Prawn::Document.generate(
        path,
        page_size: PAGE[:size],
        page_layout: PAGE[:layout],
        margin: PAGE[:margin],
        background: AssetsUtil.certificates_bg
      ) do |pdf|
        @pdf = pdf
        set_font
        # Set variables

        reports = project.reports
        count = reports.group(:type).count
        set_colors
        set_signatory

        @pdf.fill_color = @basic_text

        # Array data creation
        data = []
        data << ['WebSite Security Certificate']
        data << ["<br><br>#{I18n.t('certificate.pdf.website')}"]
        web_app_urls = add_web_app_urls(reports, data)
        data << [I18n.t('certificate.pdf.have_been')]

        data << write_numbers(count, 'scan')
        data << write_numbers(count, 'pentest') if Rails.application.config.pentest_enabled

        firstreport = I18n.l(reports.order(:edited_at).first.edited_at,
          format: :sentence)
        # Date From
        datefirstreport = date(reports.count) + firstreport
        data << ["#{datefirstreport}."]

        if transparency != 'secretive'
          # Current Level
          data << ["<br>#{I18n.t('labels.current_certification')}#{I18n.t('column')}"]
          data << [I18n.t("statistics.current_level.#{project.statistics.current_level}")]
        end

        # Signature with date
        if reports.present?
          lastreport = I18n.l(reports.order(:edited_at).last.edited_at,
            format: :sentence)
          str = @signatory_town + lastreport
        end

        data << ["<br><br>#{str}"]
        data << ["#{@signatory_name}, #{@signatory_title}"]

        draw_colored_table(data, web_app_urls, transparency)
        draw_middle_cert
        draw_page_bottom

        ####################################################################
        # Create a Second page if the transparency_level is set on clearness
        second_page(project, firstreport, count) if transparency == 'clearness'
      end
    end

    private

    def cell_style(size, align, padding)
      { size: size, align: align, border_width: 0, padding: padding, inline_format: true }
    end

    def draw_table(data, position, width, cell_style, &block)
      @pdf.table(data, position: position, width: width, cell_style: cell_style, &block)
    end

    def draw_page_bottom
      # URL at the pdf bottom
      @pdf.fill_color @informative_text
      @pdf.text_box I18n.t('certificate.pdf.presentation').to_s +
                    " <color rgb='#{@highlighted_text}'>#{CERTIFICATE_LINK}</color>",
        inline_format: true, at: [380, 30], size: 20
    end

    def write_numbers(count, follow)
      count = count["#{follow.capitalize}Report"]
      return [] if count.blank?

      number = count == 1 ? 'one' : 'multiple'
      [I18n.t("certificate.pdf.#{number}_#{follow}", number: count)]
    end

    def set_colors
      @basic_text = Customization.get_value('basic_text') || BASIC_TEXT
      @title_text = Customization.get_value('title_text') || TITLE_TEXT
      @highlighted_text = Customization.get_value('highlighted_text') || HIGHLIGHTED_TEXT
      @informative_text = Customization.get_value('informative_text') || INFORMATIVE_TEXT
    end

    def set_signatory
      @signatory_name = Customization.get_value('signatory_name') ||
                        I18n.t('certificate.pdf.signatory_name')
      @signatory_title = Customization.get_value('signatory_title') ||
                         I18n.t('certificate.pdf.signatory_title')
      @signatory_town = Customization.get_value('signatory_town') ||
                        I18n.t('certificate.pdf.signatory_town')
    end

    def prepare_table(table)
      table.column(0).text_color = @basic_text
      table.column(1).text_color = @highlighted_text
    end

    def before_stats_table(table)
      table.before_rendering_page { |tabl| prepare_table(tabl) }
    end

    def add_stats_table(project, firstreport)
      data2 = []
      t = "<br>#{I18n.t('statistics.labels.scan_reports_count')} #{I18n.t(T_DATE_SINCE)}"
      # TODO: Number of reports or only scan_reports ?
      data2 << [t + firstreport.to_s, "<br><br>#{project.statistics.scan_reports_count}"]
      str = Statistic.current_levels.keys[project.statistics.level_average]
      data2 << [I18n.t('statistics.labels.level_average'),
                I18n.t("statistics.current_level.#{str}")]
      @pdf.table(
        data2,
        width: 400,
        position: 840,
        cell_style: cell_style(19, :left, [10, -10, 10, 0])
      ) { |table| before_stats_table(table) }
    end

    def second_page(project, firstreport, count)
      @pdf.start_new_page(
        page_size: PAGE[:size], page_layout: PAGE[:layout],
        margin: PAGE[:margin], background: PAGE[:background],
        layout: PAGE[:layout]
      )
      @pdf.cell(text_color: @title_text, size: 32, at: [935, 670], border_width: 0, padding: 5,
        content: I18n.t('certificate.pdf.statistics').upcase)
      @pdf.move_down 60
      add_stats_table(project, firstreport)
      draw_stats_levels
      draw_grey_square(project)
      draw_blazons(project) if count['ScanReport'].present?
      draw_page_bottom
    end

    def draw_stats_levels
      Report.levels.keys.map(&:to_sym).each do |i|
        cert = CERT[i]
        @pdf.cell(text_color: cert[:text_color],
          at: cert[:at],
          size: 40,
          width: 200,
          height: 100,
          align: :center,
          valign: :center,
          background_color: cert[:bg_color],
          content: I18n.t("statistics.current_level.#{i}"),
          border_color: cert[:bg_color])
      end
    end

    def draw_grey_square(project)
      # Grey Square for the number of certificates obtained
      Statistic::NOFS.reverse_each do |nof_key|
        val = project.statistics.send(nof_key)
        font_color = val.zero? ? GREY : ORANGE
        @pdf.cell(text_color: font_color,
          at: NOFS_AT[nof_key],
          size: 50,
          width: 100,
          height: 100,
          align: :center,
          valign: :center,
          background_color: BG_COLOR,
          content: val,
          border_color: CERT[nof_key.to_s.sub('nof_', '').to_sym][:bg_color])
      end
    end

    def draw_blazons(project)
      # Blazon
      @pdf.cell(text_color: @basic_text, size: 14, at: [985, 430], border_width: 0, width: 200,
        content: "<b>#{I18n.t('statistics.blazon.yours').upcase}</b>",
        inline_format: true)
      @pdf.image(
        AssetsUtil.badge(project.statistics.blazon, :certificate), at: [970, 380], fit: [150, 150]
      )

      # Blazon Help
      @pdf.cell(text_color: @informative_text, size: 12, at: [830, 140], border_width: 0,
        width: 200, align: :center, valign: :center, inline_format: true,
        content: "<b>#{I18n.t('statistics.labels.score')}</b>
      <br><b><color rgb='#{@highlighted_text}'>#{project.statistics.score}</color></b>")

      Statistic.pictured_blazons.keys.each_with_index do |blazon, i|
        @pdf.image(
          AssetsUtil.badge(blazon, :pictured), at: [1020, 150 - (i * 30)], fit: [20, 20]
        )
        @pdf.text_box(
          "<color rgb='#{@informative_text}'> \
          #{I18n.t("statistics.blazon.levels.#{blazon}")}</color>",
          inline_format: true, width: 200, at: [1050, 145 - (i * 30)]
        )
      end
    end

    def set_font
      @pdf.font_families.update(
        FONT => {
          thin: AssetsUtil::FONTS_DIR.join("#{FONT}-Thin.ttf"),
          italic: AssetsUtil::FONTS_DIR.join("#{FONT}-Italic.ttf"),
          bold: AssetsUtil::FONTS_DIR.join("#{FONT}-Bold.ttf"),
          normal: AssetsUtil::FONTS_DIR.join("#{FONT}-Regular.ttf")
        }
      )
      @pdf.font FONT
    end

    def draw_middle_cert
      @pdf.image AssetsUtil.wsc('full'), at: [170, 550], fit: [525, 525]
    end

    def draw_colored_table(data, web_app_urls, transparency)
      @pdf.move_down 10

      draw_table(data.compact_blank, 820, 440, cell_style(20, :center, [5, 10, 5, 10])) do |t|
        t.row(0).text_color = @title_text
        t.row(0).size = 28
        if web_app_urls.count != 0
          t.row(2..(web_app_urls.count + 1)).text_color = @highlighted_text
        end
        t.row(-3).text_color = @highlighted_text if transparency != 'secretive'
        t.row(-2).align = :right
        t.row(-1).align = :right
      end
    end

    def perform(project, language)
      job_h = {
        progress_steps: 2,
        subscribers: project.staffs,
        title: language
      }
      handle_perform(job_h) do |job|
        path = AssetsUtil::WSC_DIR.join(
          project.fname('dir'), "#{project.fname('file')}-#{language}.pdf"
        )
        transparency = project.certificate.transparency_level
        tmplang = I18n.locale # Save language preset
        I18n.locale = language
        job.update!(status: :generating_file)
        generate_pdf(project, path, transparency)
        I18n.locale = tmplang # Re-set language preset
        job.update!(status: :completed)
      end
    end
  end
end
