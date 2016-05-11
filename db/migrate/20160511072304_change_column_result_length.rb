class ChangeColumnResultLength < ActiveRecord::Migration
  def change
  	change_column :responses, :result, :text, :limit => 4294967295
  end
end
