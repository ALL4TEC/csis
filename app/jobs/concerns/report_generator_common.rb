# frozen_string_literal: true

module ReportGeneratorCommon
  extend ActiveSupport::Concern
  include ReportGeneratorCommonConsts

  included do
    include ReportGeneratorCommonHelpers

    private

    # Build the first page
    def flyleaf_common(report, date, location)
      @pdf.move_cursor_to 50

      signatory = report.signatory.presence || report.staff
      @pdf.text signatory.full_name.to_s, size: 15
      @pdf.text "#{location}#{date}", size: 15
      @pdf.move_cursor_to 50
      @pdf.text I18n.t('pdf.website'), align: :right, size: 15
      @pdf.text I18n.t('pdf.contact'), align: :right, size: 15
    end

    # Build footer of all pages from the second one
    def footer(report, date, numeric_date)
      last = @pdf.page_number
      @pdf.go_to_page 2
      @pdf.move_down 485
      @pdf.repeat(2..last) do
        @pdf.define_grid(columns: 6, rows: 12)
        @pdf.grid(11, 0).bounding_box do
          @pdf.image reports_logo, width: 40
        end
        @pdf.grid([11, 1], [11, 4]).bounding_box do
          @pdf.move_down 15
          @pdf.text(
            I18n.t("pdf.#{report.type.downcase}.title.name") +
            " - #{report.project.client.name} - " + date,
            align: :center
          )
        end
        @pdf.grid(11, 5).bounding_box do
          @pdf.move_down 15
          @pdf.text numeric_date, align: :center
        end
        @pdf.cell(text_color: ORANGE_CONFIDENTIEL,
          content: I18n.t(T_CONFIDENTIEL),
          at: [740, 40],
          border_color: ORANGE_CONFIDENTIEL)
      end
    end

    def prepare_page(page)
      page.border_width = 0
      page.border_color = ORANGE
      page.column(0).align = :left
      page.column(1).align = :center
      page.column(2).align = :justify
      page.column(0).width = 150
      page.column(1).width = 50
      page.row(1).column(0).text_color = GREEN
      page.row(2).column(0).text_color = ORANGE_CONFIDENTIEL
      page.row(3).column(0).text_color = RED
      page.row(0).border_top_width = 2
      page.row(3).border_bottom_width = 2
      page.column(0).border_left_width = 2
      page.column(2).border_right_width = 2
    end

    def before_classification_table(table)
      table.before_rendering_page { |page| prepare_page(page) }
    end

    def add_classifications
      name_tr = 'pdf.classification.name.'
      level_tr = 'pdf.classification.level_'

      classification_data = []
      %i[public restricted confidential secret].each do |level|
        classification_data << [I18n.t("#{name_tr}#{level}"), '', I18n.t("#{level_tr}#{level}")]
      end

      @pdf.table(classification_data, cell_style: { size: 16 }) do |table|
        before_classification_table(table)
      end
    end

    def add_diffusion(report)
      diffusion_list = "#{report.project.client.name} ("
      report.contacts.each_with_index do |c, index|
        diffusion_list += ', ' if index != 0
        diffusion_list += c.full_name
      end
      diffusion_list += '), '

      @pdf.text("<color rgb='#{ORANGE}'>#{I18n.t('pdf.diffusion')} :</color> " \
                "#{diffusion_list} #{I18n.t('pdf.security_center')}",
        inline_format: true,
        align: :left,
        text_color: ORANGE_CONFIDENTIEL,
        size: 16)

      @pdf.move_down 20
      @pdf.text("<i>#{I18n.t('pdf.diffusion_text')}</i>",
        inline_format: true,
        size: 16)
    end

    # Build Confidentiality Page
    def preambule_common(report)
      @pdf.move_down 20
      @pdf.text(I18n.t('pdf.classification.level_classification'), size: 16)
      @pdf.move_down 20
      add_classifications
      @pdf.move_down 40
      add_diffusion(report)
    end
  end
end
