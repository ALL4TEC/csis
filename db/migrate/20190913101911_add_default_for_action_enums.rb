class AddDefaultForActionEnums < ActiveRecord::Migration[5.2]
  def change
    change_column_default :actions, :state, 0
    change_column_default :actions, :meta_state, 0
  end
end
