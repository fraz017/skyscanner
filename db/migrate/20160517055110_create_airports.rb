class CreateAirports < ActiveRecord::Migration
  def change
    create_table :airports do |t|
      t.string :name
      t.string :c_id
      t.float :latitude
      t.float :longitude
      t.integer :city_id

      t.timestamps null: false
    end
  end
end
