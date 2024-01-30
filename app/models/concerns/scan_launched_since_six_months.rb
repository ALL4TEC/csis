# frozen_string_literal: true

module ScanLaunchedSinceSixMonths
  extend ActiveSupport::Concern

  included do
    # By default, last scans will appear first
    default_scope -> { order(launched_at: :desc) }
    scope :recently_launched, -> { where('launched_at > ?', 6.months.ago) }
  end
end
