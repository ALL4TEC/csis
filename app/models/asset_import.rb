# frozen_string_literal: true

# Store vulnerability imports infos:
class AssetImport < Import
  before_destroy :abort_if_used_asset

  has_many :assets,
    class_name: 'Asset',
    inverse_of: :asset_import,
    primary_key: :id,
    foreign_key: :import_id,
    dependent: :destroy

  belongs_to :account,
    class_name: 'Account',
    inverse_of: :assets_imports,
    optional: true

  enum_with_select :import_type, { cyberwatch: 0 }, suffix: true

  def abort_if_used_asset
    :abort if used_assets?
  end

  # Only check if asset is linked to a project
  # Maybe check if linked to active projects ?
  def used_assets?
    assets.any? { |asset| asset.projects.count.positive? }
  end
end
