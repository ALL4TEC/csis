class AggregatesAddRank < ActiveRecord::Migration[5.2]
  def up
    add_column :aggregates, :rank, :integer
    execute <<-SQL
      UPDATE aggregates
        SET rank = computed.rank
        FROM (SELECT id, report_id, row_number() OVER (PARTITION BY kind, report_id) AS rank
              FROM aggregates
             ) computed
        WHERE computed.id = aggregates.id;
      ALTER TABLE aggregates
        ADD CONSTRAINT index_aggregates_on_report_id_and_kind_and_rank
          UNIQUE (report_id, kind, rank)
          DEFERRABLE INITIALLY IMMEDIATE;
    SQL
    change_column :aggregates, :rank, :integer, default: 1, null: false
  end

  def down
    remove_column :aggregates, :rank
    # It seems that PostgresQL automatically remove indexes referencing a removed column
    # remove_index :aggregates, column: [:report_id, :rank]
  end
end
