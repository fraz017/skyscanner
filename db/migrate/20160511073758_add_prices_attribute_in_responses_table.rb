class AddPricesAttributeInResponsesTable < ActiveRecord::Migration
  def change
  	add_column :responses, :prices, :text, :limit => 4294967295
  end
end
