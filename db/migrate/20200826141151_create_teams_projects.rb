class CreateTeamsProjects < ActiveRecord::Migration[6.0]
  def change
    create_table :teams_projects, id: false do |t|
      t.uuid 'team_id', nil: false
      t.uuid 'project_id', nil: false
      t.datetime 'created_at', nil: false
      t.index ["team_id", "project_id"], name: "index_teams_projects", unique: true
    end

    Project.all.each do |p|
      p.update(team_ids: [p.team_id])
    end

    remove_column :projects, :team_id
  end
end
