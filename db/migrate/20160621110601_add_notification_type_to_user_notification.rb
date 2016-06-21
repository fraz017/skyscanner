class AddNotificationTypeToUserNotification < ActiveRecord::Migration
  def change
    add_column :user_notifications, :notification_type, :string
  end
end
