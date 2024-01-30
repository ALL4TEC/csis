class AggregatesRenameVulnTypeToStatus < ActiveRecord::Migration[5.2]
  def change
    rename_column :aggregates, :vuln_type, :status
  end
end
