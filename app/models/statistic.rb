# frozen_string_literal: true

MAX_SCORE = 4096
MIN_SCORE = 0
SCORE_RANGES = [
  (0..974), (975..1949), (1950..3119), (3120..MAX_SCORE)
].freeze

class Statistic < ApplicationRecord
  include EnumSelect
  has_paper_trail

  belongs_to :project,
    class_name: 'Project',
    primary_key: :id,
    inverse_of: :statistics

  has_many :reports, through: :project

  enum_with_select :current_level, {
    in_progress: 0,
    satisfactory: 1,
    good: 2,
    very_good: 3,
    excellent: 4
  }

  enum_with_select :blazon, { black: 0, bronze: 1, silver: 2, gold: 3 }

  NOFS = %i[nof_in_progress nof_satisfactory nof_good nof_very_good nof_excellent].freeze

  # Fill the map containing attributes to update before calling update(map)
  def update_stats
    update_h = {}
    update_h.merge!(update_score)
    update_h.merge!(update_scans_count)
    update_h.merge!(certif_level)
    update_h.merge!(update_average)
    update_h.merge!(update_scan_reports_count)
    update_h.merge!(update_pentest_reports_count) if Rails.application.config.pentest_enabled
    if Rails.application.config.action_plan_enabled
      update_h.merge!(update_action_plan_reports_count)
    end
    update_h.merge!(count_levels)
    update_h.merge!(update_blazon)
    update(update_h)
  end

  # Update the score with : (Tir*12) + ( (Tir-1) * 11 ) ....
  # S = 12 * (12 + 1)/2 * 5 * 10 = 3900: MAX_SCORE
  def update_score
    points = 0
    reports.order(edited_at: :desc)[0..11].each_with_index do |r, index|
      points += (5 - r.severity) * (12 - index)
    end
    { score: points * 10 }
  end

  def update_action_plan_reports_count
    return unless Rails.application.config.action_plan_enabled

    { action_plan_reports_count: reports.of_action_plan_type.count }
  end

  def update_scan_reports_count
    { scan_reports_count: reports.of_scan_type.count }
  end

  def update_pentest_reports_count
    return unless Rails.application.config.pentest_enabled

    { pentest_reports_count: reports.of_pentest_type.count }
  end

  def update_scans_count
    { scans_count: project.wa_scans.count + project.vm_scans.count }
  end

  # Return the most important severity from the latest scan
  # Permit to chose the certificat to apply
  def certif_level
    ({ current_level: (4 - reports.order(:edited_at).last.severity) } if reports.present?) || {}
  end

  # Return an average of all certif_level
  def update_average
    rep = reports.count
    ({ level_average: (4 - (reports.sum(&:severity) / rep)) } if rep.positive?) || {}
  end

  # Count the number of each level of certificate
  def count_levels
    level = reports.where(type: 'ScanReport').map { |report| 4 - report.severity }
    c = {}
    NOFS.each_with_index do |nof, i|
      c[nof] = level.count(i)
    end
    c
  end

  # Set number of blazon the client has
  def update_blazon
    SCORE_RANGES.each_with_index do |range, i|
      break { blazon: i } if score.in?(range)
    end
  end

  class << self
    def pictured_blazons
      blazons.except(:black)
    end
  end
end
