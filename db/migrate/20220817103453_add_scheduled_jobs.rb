class AddScheduledJobs < ActiveRecord::Migration[6.1]
  def change
    create_table :scheduled_jobs, id: :uuid, default: -> { "uuid_generate_v4()" } do |t|
      t.string :name, null: false, default: ''
      t.jsonb :configuration

      t.timestamps
    end
  end
end
