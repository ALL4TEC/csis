class RestartVersionsSequenceToLast < ActiveRecord::Migration[6.1]
  def change
    say_with_time "Restart versions sequence to last" do
      if PaperTrail::Version.count.positive?
        current = PaperTrail::Version.last.id
        query = <<-SQL
          ALTER SEQUENCE versions_range_records_id_seq RESTART WITH #{current + 1}
        SQL
        ActiveRecord::Base.connection.execute(query)
      end
    end
  end
end
