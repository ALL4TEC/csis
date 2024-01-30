class CreateAggregatesActions < ActiveRecord::Migration[5.2]
  def change
    create_table :aggregates_actions, id: false do |t|
      t.uuid 'aggregate_id', nil: false
      t.uuid 'action_id', nil: false
      t.datetime 'created_at', nil: false
      t.index ["aggregate_id", "action_id"], name: "index_aggregates_actions", unique: true
    end

    Action.all.each do |a|
      a.update(aggregate_ids: [a.aggregate_id])
    end

    remove_column :actions, :aggregate_id
  end
end
