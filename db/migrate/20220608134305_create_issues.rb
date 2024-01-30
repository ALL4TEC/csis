class CreateIssues < ActiveRecord::Migration[6.1]
  def change
    create_table :issues, id: :uuid, default: -> { "uuid_generate_v4()" } do |t|
      t.uuid 'action_id', nil: false
      t.references :ticketable, polymorphic: true, type: :uuid
      t.integer :status, null: false

      t.timestamps
    end
  end
end
