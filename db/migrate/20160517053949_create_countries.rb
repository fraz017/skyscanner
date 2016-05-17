class CreateCountries < ActiveRecord::Migration
  def change
    create_table :countries do |t|
      t.string :c_id
      t.string :name
      t.string :currency
      t.string :language
      t.integer :continent_id

      t.timestamps null: false
    end
  end
end
