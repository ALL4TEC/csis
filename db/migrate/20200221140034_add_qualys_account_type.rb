class AddQualysAccountType < ActiveRecord::Migration[5.2]
  def change
    add_column :qualys_configs, :kind, :integer, default: 0, null: false
  end
end
