class ChangeColumnIdType < ActiveRecord::Migration
  def change
  	change_column :responses, :user_id, :string
  end
end
