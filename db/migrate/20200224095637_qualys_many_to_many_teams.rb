class QualysManyToManyTeams < ActiveRecord::Migration[5.2]
  def up
    create_table "qualys_configs_teams", id: false, force: :cascade do |t|
      t.uuid "qualys_config_id", null: false
      t.uuid "team_id", null: false
      t.index ["qualys_config_id", "team_id"], name: "index_qualys_configs_teams", unique: true
    end

    # Pour chaque team ayant un qualys_config_id, on crée une ligne dans qualys_configs_teams
    Team.all.each do |team|
      QualysConfigTeam.create(qualys_config_id: team.qualys_config_id, team_id: team.id) if team.qualys_config_id.present?
    end

    remove_column "teams", "qualys_config_id"
    # On lie les scans à une config qualys lors de l'import qualys
    add_column "vm_scans", "qualys_config_id", :uuid
    add_column "wa_scans", "qualys_config_id", :uuid

    create_table "qualys_vm_clients_teams", id: false, force: :cascade do |t|
      t.uuid "qualys_vm_client_id", null: false
      t.uuid "team_id", null: false
      t.index ["qualys_vm_client_id", "team_id"], name: "index_qualys_vm_clients_teams", unique: true
    end

    # Pour chaque qualys_vm_client ayant un team_id, on crée une ligne dans qualys_vm_clients_teams
    QualysVmClient.all.each do |qvc|
      QualysVmClientTeam.create(qualys_vm_client_id: qvc.id, team_id: qvc.team_id) if qvc.team_id.present?
    end

    remove_column "qualys_vm_clients", "team_id"

    create_table "qualys_wa_clients_teams", id: false, force: :cascade do |t|
      t.uuid "qualys_wa_client_id", null: false
      t.uuid "team_id", null: false
      t.index ["qualys_wa_client_id", "team_id"], name: "index_qualys_wa_clients_teams", unique: true
    end

    # Pour chaque qualys_wa_client ayant un team_id, on crée une ligne dans qualys_wa_clients_teams
    QualysWaClient.all.each do |qwc|
      QualysWaClientTeam.create(qualys_wa_client_id: qwc.id, team_id: qwc.team_id) if qwc.team_id.present?
    end

    remove_column "qualys_wa_clients", "team_id"
  end

  def down
    add_column "teams", "qualys_config_id", :uuid
    # On récupère la première ligne de la jointure que l'on set dans qualys_config.team_id
    QualysConfigTeam.all.each do |qct|
      qct.qualys_config.update(team_id: qct.first.team_id)
    end
    drop_table "qualys_configs_teams"

    # On lie les scans à une config qualys lors de l'import qualys
    remove_column "vm_scans", "qualys_config_id"
    remove_column "wa_scans", "qualys_config_id"

    add_column "qualys_vm_clients", "team_id", :uuid
    # On récupère la première ligne de la jointure que l'on set dans qualys_vm_client.team_id
    QualysVmClientTeam.all.each do |qvct|
      qvct.qualys_vm_client.update(team_id: qvct.first.team_id)
    end
    drop_table "qualys_vm_clients_teams"

    add_column "qualys_wa_clients", "team_id", :uuid
    # On récupère la première ligne de la jointure que l'on set dans qualys_wa_client.team_id
    QualysWaClientTeam.all.each do |qwct|
      qwct.qualys_wa_client.update(team_id: qwct.first.team_id)
    end
    drop_table "qualys_wa_clients_teams"
  end
end
