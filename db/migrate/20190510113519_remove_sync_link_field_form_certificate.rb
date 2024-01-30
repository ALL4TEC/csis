class RemoveSyncLinkFieldFormCertificate < ActiveRecord::Migration[5.2]
  def change
    remove_column :certificates, :sync_link
  end
end
