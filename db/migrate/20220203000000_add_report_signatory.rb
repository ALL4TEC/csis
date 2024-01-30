class AddReportSignatory < ActiveRecord::Migration[6.1]
  def change
    add_column :reports, :signatory_id, :uuid
    add_foreign_key :reports, :users, column: :signatory_id, on_delete: :nullify
  end
end
