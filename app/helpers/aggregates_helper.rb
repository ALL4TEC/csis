# frozen_string_literal: true

module AggregatesHelper
  # Map donnant accès à la traduction
  # d'une sévérité d'aggrégat à partir du symbol/hash
  T_ILLIMITED_TIME = 'pdf.score_tab.illimited_time'
  T_FALSE_POSITIVE = 'pdf.score_tab.false_positive'
  T_MAJOR_CORRECTION = 'pdf.score_tab.major_correction'
  T_MINOR_CORRECTION = 'pdf.score_tab.minor_correction'
  T_48H_CORRECTION = 'pdf.score_tab.48h_correction'
  T_IMMEDIATE_CORRECTION = 'pdf.score_tab.immediate_correction'
  SEVERITY = {
    falsepositive: {
      fill_color: WHITE,
      text_color: BLACK,
      translation: T_FALSE_POSITIVE
    },
    trivial: {
      fill_color: '639139',
      text_color: WHITE,
      translation: T_ILLIMITED_TIME
    },
    low: {
      fill_color: 'FCE6A3',
      text_color: BLACK,
      translation: T_MAJOR_CORRECTION
    },
    medium: {
      fill_color: 'FFCC00',
      text_color: BLACK,
      translation: T_MINOR_CORRECTION
    },
    high: {
      fill_color: 'FF5C1C',
      text_color: WHITE,
      translation: T_48H_CORRECTION
    },
    critical: {
      fill_color: 'DB2619',
      text_color: WHITE,
      translation: T_IMMEDIATE_CORRECTION
    }
  }.freeze

  T_STATUS = {
    information_gathered: 'labels.gathered_information',
    vulnerability_or_potential_vulnerability: 'labels.sensitive_information',
    potential_vulnerability: 'pdf.tab.potential',
    vulnerability: 'pdf.tab.confirmed'
  }.freeze

  AGGREGATE_ACTIONS = {
    order: {
      icon: :ordered_list
    },
    duplicate: {
      icon: :duplicate
    },
    delete: {
      icon: :delete
    }
  }.freeze

  def self.translate_status(status)
    I18n.t(T_STATUS[status.to_sym])
  end

  # Permit to print severities with correct colors
  # @param severity: Aggregate severity
  def translate_severity(severity)
    AggregatesHelper.translate_severity(severity)
  end

  # Permit to print severities with correct colors
  # @param severity: Aggregate severity
  def self.translate_severity(severity)
    I18n.t(SEVERITY[severity.to_sym][:translation])
  end

  # Permit to print severities with correct colors
  # @param severity: Aggregate severity
  def self.color_fill_severity(severity)
    SEVERITY[severity.to_sym][:fill_color]
  end

  # Permit to print severities with correct colors
  # @param severity: Aggregate severity
  def self.color_text_severity(severity)
    SEVERITY[severity.to_sym][:text_color]
  end

  def aggregate_action_icon(action)
    AGGREGATE_ACTIONS[action.to_sym][:icon]
  end
end
