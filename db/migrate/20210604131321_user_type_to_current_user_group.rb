class UserTypeToCurrentUserGroup < ActiveRecord::Migration[6.1]
  def change
    add_column :users_groups, :current, :boolean, null: false, default: false
    say_with_time "Rename groups staffs to staff" do
      query = <<-SQL
        UPDATE groups
        SET name = 'staff'
        WHERE name = 'staffs'
      SQL
      ActiveRecord::Base.connection.execute(query)
    end
    say_with_time "Rename groups contacts to contact" do
      query = <<-SQL
        UPDATE groups
        SET name = 'contact'
        WHERE name = 'contacts'
      SQL
      ActiveRecord::Base.connection.execute(query)
    end
    rename_column :users, :type, :old_type # Bypass STI
    say_with_time "Replace User.type by users_groups.current" do
      User.where(old_type: 'Staff').each do |user|
        user.users_groups.where(group: Group.staff).update(current: true)
      end
      User.where(old_type: 'Contact').each do |user|
        user.users_groups.where(group: Group.contact).update(current: true)
      end
    end
    remove_column :users, :old_type
    remove_column :comments, :author_type
  end
end
