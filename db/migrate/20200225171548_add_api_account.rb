class AddApiAccount < ActiveRecord::Migration[5.2]
  def change
    rename_table :qualys_configs, :api_accounts
    change_table :api_accounts do |t|
      t.string  :type, default: 'QualysConfig', null: false
    end

    create_table :qualys_configs, id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
      t.uuid :qualys_config_id
      t.integer :kind, default: 0, null: false
    end

    remove_column :api_accounts, :kind
  end
end
