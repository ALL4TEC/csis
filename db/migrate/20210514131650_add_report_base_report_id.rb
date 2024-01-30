class AddReportBaseReportId < ActiveRecord::Migration[6.1]
  def change
    add_column :reports, :base_report_id, :uuid
  end
end
