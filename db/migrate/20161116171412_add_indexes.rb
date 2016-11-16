class AddIndexes < ActiveRecord::Migration[5.0]
  def change
  	  add_index :code_processes, :prefix
  	  add_index :code_processes, :carrier_prefix
  	  add_index :code_processes, :start_date
  	  add_index :codes, :prefix
  	  add_index :rates, :prefix
  	  add_index :rates, :flag1
  	  add_index :rates, :flag2
  	  add_index :rates, :flag3
  end
end
