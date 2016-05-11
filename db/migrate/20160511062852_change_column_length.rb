class ChangeColumnLength < ActiveRecord::Migration
  def change
  	change_column :responses, :result, :text, :limit => nil
  end
end
