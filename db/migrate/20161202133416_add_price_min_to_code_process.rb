class AddPriceMinToCodeProcess < ActiveRecord::Migration[5.0]
  def change
    add_column :code_processes, :price_min, :decimal
  end
end
