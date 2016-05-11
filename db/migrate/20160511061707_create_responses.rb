class CreateResponses < ActiveRecord::Migration
  def change
    create_table :responses do |t|
      t.text :result, :limit => nil
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
