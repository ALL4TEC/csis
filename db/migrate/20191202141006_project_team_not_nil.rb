class ProjectTeamNotNil < ActiveRecord::Migration[5.2]
  def change
    change_column :projects, :team_id, :uuid, null: false
  end
end
