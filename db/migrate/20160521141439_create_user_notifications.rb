class CreateUserNotifications < ActiveRecord::Migration
  def change
    create_table :user_notifications do |t|
      t.string :name
      t.string :email
      t.float :price
      t.text :query

      t.timestamps null: false
    end
  end
end
