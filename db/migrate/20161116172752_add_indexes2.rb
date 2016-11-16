class AddIndexes2 < ActiveRecord::Migration[5.0]
  def change
  	  add_index :code_processes, :carrier_price1
  	  add_index :code_processes, :carrier_price2
  	  add_index :code_processes, :carrier_price4
  	  add_index :rates, :price_min
  end
end
