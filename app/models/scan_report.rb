# frozen_string_literal: true

# = ScanReport
#
# Le modèle ScanReport correspond à un rapport de type scan

class ScanReport < Report
  has_one :ext,
    class_name: 'ScanReportExt',
    inverse_of: :report,
    primary_key: :id,
    dependent: :destroy,
    autosave: true

  delegate :vm_introduction, :vm_introduction=, to: :lazily_built_ext
  delegate :wa_introduction, :wa_introduction=, to: :lazily_built_ext

  private

  after_initialize do
    if new_record?
      # values will be available for new record forms.
      self.base_report_id = project.last_report('ScanReport')&.id
    end
  end

  def lazily_built_ext
    ext || build_ext
  end
end
