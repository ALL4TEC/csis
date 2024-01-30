class RenameVersionsTables < ActiveRecord::Migration[6.1]
  def change
    ActiveRecord::Base.connection.tables.select do |table|
      table.in?(PaperTrail::Version.partitions.select { |table| table.length == 17 })
    end.each do |table_name|
      # table_name here is 'versions_yxxxx_mz'
      # we want 'versions_yxxxx_m0z'
      # To list all tables:
      # ActiveRecord::Base.connection.tables
      # To list partitioned tables
      # PaperTrail::Version.partitions
      new_table_name = String.new(table_name)
      new_table_name.insert(16, '0')
      rename_table table_name, new_table_name
    end
  end
end
