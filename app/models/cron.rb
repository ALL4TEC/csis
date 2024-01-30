# frozen_string_literal: true

class Cron < ApplicationRecord
  belongs_to :cronable,
    polymorphic: true,
    optional: true

  def self.cronable_types
    %w[Account Project ScanLaunch ScheduledScan]
  end

  validates :cronable_type, inclusion: { in: Cron.cronable_types }
  validates_with CronValidator, field: :value

  def to_s
    value
  end
end
