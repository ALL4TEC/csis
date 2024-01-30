# frozen_string_literal: true

class AssetProject < ApplicationRecord
  self.table_name = 'assets_projects'

  belongs_to :asset,
    class_name: 'Asset',
    inverse_of: :assets_projects,
    primary_key: :id

  belongs_to :project,
    class_name: 'Project',
    inverse_of: :assets_projects,
    primary_key: :id
end
