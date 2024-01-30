class CommentAuthorIsNowPolymorphic < ActiveRecord::Migration[6.0]
  def change
    add_column :comments, :author_id, :uuid
    add_column :comments, :author_type, :string

    # Transform strings into associations
    Comment.all.each do |c|
      str = c.attributes['author'] # Get attributes without going through associations
      author = Staff.find_by(full_name: str) || Contact.find_by(full_name: str)
      c.update(author: author)
    end

    remove_column :comments, :author
  end
end
