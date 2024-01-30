class FixJpegContentType < ActiveRecord::Migration[6.1]
  def change
    say_with_time "Fix active_storage_blobs jpeg content_type" do
      query = <<-SQL
        UPDATE active_storage_blobs SET content_type = 'image/jpeg' WHERE content_type = 'image/jpg'
      SQL
      ActiveRecord::Base.connection.execute(query)
    end
  end
end
