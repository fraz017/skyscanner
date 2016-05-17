class CreateContinents < ActiveRecord::Migration
  def change
    create_table :continents do |t|
      t.string :name
      t.string :c_id

      t.timestamps null: false
    end
  end
end
