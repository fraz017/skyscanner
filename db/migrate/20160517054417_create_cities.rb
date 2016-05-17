class CreateCities < ActiveRecord::Migration
  def change
    create_table :cities do |t|
      t.string :name
      t.string :c_id
      t.float :latitude
      t.float :longitude
      t.string :iatacode
      t.integer :country_id

      t.timestamps null: false
    end
  end
end
