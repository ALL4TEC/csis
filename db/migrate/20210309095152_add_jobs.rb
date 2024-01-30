class AddJobs < ActiveRecord::Migration[6.1]
  def change
    create_table "jobs", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
      t.uuid "creator_id"
      t.string "resque_job_id"
      t.integer 'progress_step', default: 0
      t.integer 'progress_steps'
      t.string 'clazz'
      t.string "status", default: 'init'
      t.string "title"
      t.text "stacktrace"
      t.timestamps
      # t.string "kubernetes_job_id"
      t.index ["resque_job_id"], name: "index_jobs_on_resque_job_id"
    end

    create_table "jobs_subscriptions", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
      t.uuid "job_id"
      t.uuid "subscriber_id"
    end

    add_column :scan_launches, :csis_job_id, :uuid
    add_foreign_key :scan_launches, :jobs, column: :csis_job_id, primary_key: :id, on_delete: :nullify
  end
end
