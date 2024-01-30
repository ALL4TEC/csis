class MovePmtReferenceToIssue < ActiveRecord::Migration[6.1]
  def change
    remove_column :actions, :pmt_reference
    add_column :issues, :pmt_reference, :string

    # TODO: create a special ticketing account for the old pmt_name and pmt_reference values
  end
end
