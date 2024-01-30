# frozen_string_literal: true

class AssetTarget < ApplicationRecord
  self.table_name = 'assets_targets'

  belongs_to :asset,
    class_name: 'Asset',
    inverse_of: :assets_targets,
    primary_key: :id

  belongs_to :target,
    class_name: 'Target',
    inverse_of: :assets_targets,
    primary_key: :id
end
