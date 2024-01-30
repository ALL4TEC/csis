class AddReportImportAutoOccurencesAggregation < ActiveRecord::Migration[6.1]
  def change
    add_column :report_imports, :auto_aggregate, :boolean, null: false, default: true
    add_column :report_imports, :auto_aggregate_mixing, :boolean, null: false, default: true
    add_column :scan_launches, :auto_aggregate, :boolean, null: false, default: true
    add_column :scan_launches, :auto_aggregate_mixing, :boolean, null: false, default: true
  end
end
