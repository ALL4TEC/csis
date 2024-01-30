# frozen_string_literal: true

class TargetScan < ApplicationRecord
  self.table_name = :targets_scans

  belongs_to :target,
    class_name: 'Target',
    inverse_of: :target_scans,
    primary_key: :id

  belongs_to :scan,
    polymorphic: true

  validates :scan_type,
    inclusion: { in: %w[VmScan WaScan] }
end
