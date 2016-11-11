class AddNameToExchangeRates < ActiveRecord::Migration[5.0]
  def change
    add_column :exchange_rates, :name, :string
  end
end
