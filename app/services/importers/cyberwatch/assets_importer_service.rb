# frozen_string_literal: true

class Importers::Cyberwatch::AssetsImporterService
  API_PATH = 'v3/assets/servers'

  # @param **assets_import:** AssetsImport
  # @param **opts:** Options passed to Cyberwatch lib
  def self.import_assets(asset_import, opts)
    new.handle_import(asset_import, opts)
  end

  def handle_import(asset_import, opts)
    asset_import.update(status: :processing)
    assets = ::Cyberwatch::Request.do_list(asset_import.account, API_PATH, opts)
    handle_assets(assets, asset_import)
    asset_import.update(status: :completed)
  end

  private

  def handle_assets(assets, asset_import)
    account_id = asset_import.account.id
    assets.each { |asset| handle_asset(asset, account_id) }
  end

  # Find or create asset
  # @param **asset:** Cyberwatch asset
  # @param **account_id:** CyberwatchConfig id
  # @return persisted Asset
  def handle_asset(asset, account_id)
    asset_name = asset['hostname'] || "CBW-#{asset['id']}"
    return if Asset.kept.find_by(name: asset_name)

    created_asset = Asset.create!(CyberwatchMapper.asset_h(asset, account_id))
    Target.create!(CyberwatchMapper.target_h(created_asset))
  end
end
