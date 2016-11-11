class AddFoundPriceToRate < ActiveRecord::Migration[5.0]
  def change
    add_column :rates, :found_price, :decimal
  end
end
