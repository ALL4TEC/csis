class AddFieldsProjectManagementAction < ActiveRecord::Migration[5.2]
  def change
    add_column :actions, :pmt_name, :text
    add_column :actions, :pmt_reference, :text
  end
end
