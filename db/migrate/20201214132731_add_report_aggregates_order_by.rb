class AddReportAggregatesOrderBy < ActiveRecord::Migration[6.0]
  def change
    add_column :reports, :aggregates_order_by, :text, default: ['status', 'severity', 'visibility', 'title'].to_yaml
  end
end
