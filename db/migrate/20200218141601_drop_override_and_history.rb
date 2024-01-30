class DropOverrideAndHistory < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :histories, :reports
    remove_foreign_key :histories, :vulnerabilities
    drop_table :histories

    remove_foreign_key :overrides, :projects
    remove_foreign_key :overrides, :vulnerabilities
    drop_table :overrides
  end
end
