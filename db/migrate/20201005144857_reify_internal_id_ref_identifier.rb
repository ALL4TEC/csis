class ReifyInternalIdRefIdentifier < ActiveRecord::Migration[6.0]
  def change
    # CLIENTS
    change_column :clients, :internal_id, :string
    rename_column :clients, :internal_id, :ref_identifier
    # Update clients values to SELLSY_<value>
    say_with_time 'Moving clients internal_id to ref_identifier' do
      query = <<-SQL
        UPDATE clients
        SET ref_identifier = CONCAT('SELLSY_', ref_identifier)
        WHERE ref_identifier IS NOT NULL
      SQL
      ActiveRecord::Base.connection.execute(query)
    end
    # Update users values to SELLSY_<value>
    say_with_time 'Moving contacts internal_id to ref_identifier' do
      query = <<-SQL
        UPDATE users
        SET ref_identifier = CONCAT('SELLSY_', internal_id)
        WHERE internal_id IS NOT NULL
      SQL
      ActiveRecord::Base.connection.execute(query)
    end
    remove_column(:users, :internal_id)
  end
end
