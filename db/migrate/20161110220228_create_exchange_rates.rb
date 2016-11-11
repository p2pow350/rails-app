class CreateExchangeRates < ActiveRecord::Migration[5.0]
  def change
    create_table :exchange_rates do |t|
      t.date :start_date
      t.string :currency
      t.decimal :rate

      t.timestamps
    end
  end
end
