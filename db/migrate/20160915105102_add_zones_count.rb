class AddRatesCount < ActiveRecord::Migration[5.0]
  def change
  	  add_column :carriers, :rates_count, :integer, default: 0
  end
end
