class AddCurrencyToCarrier < ActiveRecord::Migration[5.0]
  def change
    add_column :carriers, :currency, :string
  end
end
