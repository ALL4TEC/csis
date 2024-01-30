class AddSeverityNotification < ActiveRecord::Migration[6.0]
  def change
    add_column :projects, :notification_severity_threshold, :integer
  end
end
