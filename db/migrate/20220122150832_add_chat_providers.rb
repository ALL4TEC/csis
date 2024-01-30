class AddChatProviders < ActiveRecord::Migration[6.1]
  def change
    # Ajout ExternalApplication
    create_table :external_applications, id: :uuid, default: 'uuid_generate_v4()' do |t|
      t.string :app_id
      t.string :name
      t.string :encrypted_client_id, null: true
      t.string :encrypted_client_id_iv, null: true
      t.string :encrypted_client_secret, null: true
      t.string :encrypted_client_secret_iv, null: true
      t.string :encrypted_signing_secret, null: true
      t.string :encrypted_signing_secret_iv, null: true
      t.string :type, default: 'SlackApplication', null: false
    end

    # Renommage SlackConfigs en ChatConfigs
    rename_table :slack_configs, :chat_configs
    # Historiquement les accounts.type liés aux slack_configs sont à SlackConfig
    # Extension de la table accounts => Nécessite un identifiant
    rename_column :chat_configs, :slack_config_id, :chat_config_id
    # # Ajout de la colonne type par défaut à SlackConfig
    # add_column :chat_configs, :type, :string, default: 'SlackConfig', null: false
    add_column :accounts, :external_application_id, :uuid
    add_foreign_key :accounts, :external_applications, column: :external_application_id, primary_key: :id, on_delete: :nullify

    # Ajout des colonnes communes
    add_column :chat_configs, :workspace_name, :string
    add_column :chat_configs, :channel_name, :string
    add_column :chat_configs, :bot_name, :string
    add_column :chat_configs, :webhook_domain, :string
  end
end
