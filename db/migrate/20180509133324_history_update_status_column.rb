class HistoryUpdateStatusColumn < ActiveRecord::Migration[5.2]
  def change
    change_column :histories, :status, :integer, using: 'status::integer'
  end
end
