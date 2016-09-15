class CreateRates < ActiveRecord::Migration[5.0]
  def change
    create_table :rates do |t|
      t.references :zone, foreign_key: true
      t.references :carrier, foreign_key: true
      t.string :name
      t.string :prefix
      t.decimal :price_min
      t.integer :step
      t.datetime :start_date
      t.integer :status

      t.timestamps
    end
  end
end
