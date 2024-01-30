class SplitNotifications < ActiveRecord::Migration[6.1]
  def change
    # For performance reasons, we clean existing notifications of more than 1 month and all read ones
    say_with_time 'Purging old notifications' do
      query = "DELETE FROM notifications WHERE created_at < '#{1.month.ago}' OR state != 0"
      ActiveRecord::Base.connection.execute(query)
    end

    create_table "notifications_subscriptions", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
      t.uuid "notification_id"
      t.uuid "subscriber_id"
      t.integer "state", default: 0
      t.datetime "discarded_at"
      t.index ["discarded_at"], name: "index_notifications_subscriptions_on_discarded_at"
      t.index ["notification_id", "subscriber_id"], name: "index_notifications_subscriptions", unique: true
    end

    # Group notifications per version_id
    query = 'SELECT DISTINCT version_id FROM notifications'
    version_ids_results = ActiveRecord::Base.connection.execute(query)
    version_ids_results.each do |data|
      version_id = data['version_id']
      query = "SELECT id FROM notifications WHERE version_id = #{version_id} LIMIT 1"
      first_notification_id = ActiveRecord::Base.connection.execute(query).first['id']
      say_with_time "Moving notifications to notifications_subscriptions for version: #{version_id}" do
        # Create notification_subscription for each notification grouped by version_id pointing to first notification of group
        query = "INSERT INTO notifications_subscriptions (notification_id, subscriber_id, state, discarded_at)\
          SELECT '#{first_notification_id}', resource_id, state, discarded_at\
          FROM notifications WHERE version_id = #{version_id}"
        ActiveRecord::Base.connection.execute(query)
        # Delete moved notifications
        query = "DELETE FROM notifications WHERE version_id = #{version_id} AND id != '#{first_notification_id}'"
        ActiveRecord::Base.connection.execute(query)
      end
    end

    # Remove indexes
    remove_index :notifications, name: 'index_notifications_on_resource_type_and_resource_id'
    remove_index :notifications, name: 'index_notifications_on_discarded_at'
    # Remove useless attributes
    remove_column :notifications, :state
    remove_column :notifications, :discarded_at
    remove_column :notifications, :resource_id
    remove_column :notifications, :resource_type
    add_index :notifications, :version_id, unique: true
    # Notifications mails configuration per user needs an event symbol
    add_column :notifications, :subject, :integer
    # Add configuration column in users table to send mails on some notification events
    # comma separated notification events, enables not to have to migrate each time a new notification event appears
    add_column :users, :send_mail_on, :text, array: true, default: ['exceeding_severity_threshold']
    add_column :users, :notify_on, :text, array: true, default: ["action_state_update", "comment_creation", "export_generation", "scan_launch_done", "scan_created", "scan_destroyed", "exceeding_severity_threshold"]
  end
end
