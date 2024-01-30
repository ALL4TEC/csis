class AddCrons < ActiveRecord::Migration[6.1]
  def change
    create_table "crons", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
      t.string "name"
      t.uuid "cronable_id"
      t.string "cronable_type"
      t.string "value"
      t.index ["name", "cronable_type", "cronable_id"], name: "index_crons_on_name_and_res_type_and_res_id", unique: true
    end

    say_with_time 'Moving projects.schedules to new crons' do
      query = "SELECT * FROM projects WHERE auto_generate = true AND NOT ((schedule = '' OR schedule IS NULL))"
      projects_data = ActiveRecord::Base.connection.execute(query)
      projects_data.each do |data|
        project = Project.find(data['id'])
        schedule = data['schedule']
        project.report_auto_generation_cron = schedule
        project.save! # Triggers after_update callback
      end
    end

    say_with_time 'Adding default vm_import_cron and wa_import_cron value for each QualysConfig' do
      cron_value = '0 2 * * *'
      QualysConfig.all.each do |qc|
        KindUtil.scan_accros.each do |accro|
          qc.send('import_cron=', accro, cron_value)
          qc.save! # Triggers after_update callback
        end
      end
    end
    remove_column :projects, :schedule
  end
end
