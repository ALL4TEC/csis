# frozen_string_literal: true

module ReportGeneratorCommonConsts
  SCORING = 'scoring'
  DIFF = 'Diff'
  T_CONFIDENTIEL = 'pdf.classification.name.confidential'
  T_SEVERITY = 'labels.severity'
  T_TOTAL = 'pdf.tab.total'
  T_SCORING = 'pdf.tab.scoring'

  def reports_logo
    AssetsUtil.reports_logo
  end

  def badge(level)
    AssetsUtil.badge(level)
  end
end
