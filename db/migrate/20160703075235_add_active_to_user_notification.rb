class AddActiveToUserNotification < ActiveRecord::Migration
  def change
    add_column :user_notifications, :active, :boolean, default: true
  end
end
