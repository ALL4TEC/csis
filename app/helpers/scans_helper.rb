# frozen_string_literal: true

module ScansHelper
  CONFIGS_LOGOS = {
    QualysConfig: :qualys,
    InsightAppSecConfig: :rapid7,
    CyberwatchConfig: :cyberwatch
  }.freeze

  def scan_logo(scan)
    Icons::LOGOS[logo_name(scan)]
  end

  def logo_name(scan)
    if scan.scan_import.present?
      scan.scan_import.import_type.to_sym
    elsif scan.account.present?
      CONFIGS_LOGOS[scan.account.type.to_sym]
    else
      :qualys # By default, historically
    end
  end
end
