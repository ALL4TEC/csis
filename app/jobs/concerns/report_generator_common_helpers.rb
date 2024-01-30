# frozen_string_literal: true

module ReportGeneratorCommonHelpers
  # Permit to print status with correct colors
  # @param status
  def translate_status(status)
    "<color rgb='#{BLACK}'>#{AggregatesHelper.translate_status(status)}</color>"
  end

  # Build supped string
  def sup(arg)
    "<sup>(#{arg})</sup>"
  end

  # Build bolded string
  def bold(arg)
    "<b>#{arg}</b>"
  end

  # Return the number of columns for score table
  # @param type Type de Scan (system or applicative)
  def columns_nb(type)
    type == :system ? 4 : 5
  end

  private

  def progressify(section)
    Rails.logger.info "Generated; section='#{section.to_s.humanize}'"
    @job.update!(status: section)
  end

  # Show page numbering of all the document
  def page_numbering
    string = '<page>/<total>'
    options = {
      at: [@pdf.bounds.right - 150, 10],
      width: 150,
      align: :right,
      page_filter: :all,
      start_count_at: 1,
      color: '333333'
    }
    @pdf.number_pages string, options
  end

  # Create a new page with its title
  def page_title(title, link_dest)
    @pdf.start_new_page
    @pdf.add_dest(link_dest, @pdf.dest_xyz(@pdf.bounds.absolute_left, @pdf.y))
    @pdf.text title, size: 25
    @pdf.stroke_color ORANGE
    @pdf.line [0, 540], [@pdf.bounds.right, 540]
    @pdf.stroke
    @pdf.move_down 20
    @pdf.stroke_color BLACK
  end
end
